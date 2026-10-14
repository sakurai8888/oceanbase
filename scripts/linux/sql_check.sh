#!/bin/bash

# ================= Configuration ================= ./sql_audit.sh 001 /path/sql/
SCAN_ID="${1}"

echo $SCAN_ID

OB_HOST="192.168.1.200"
OB_PORT="2883"
OB_USER="oratest01@oratenant01#obclu"
OB_PASS="Aa12345678"
OB_DB="ORATEST01"

SQL_DIR="${2}"
CSV_REPORT="obclient_audit_report_${SCAN_ID}.csv"
SUMMARY_LOG="obclient_audit_errors_${SCAN_ID}.log"
# =================================================

# Ignore valid syntax errors caused by missing DB tables, procedures, or PL/SQL identifiers
IGNORE_OBJECT_ERRORS="does not exist|doesn't exist|ORA-00942|unknown column|Unknown table|OBE-05151|PLS-[0-9]+|ORA-06550|must be declared"

echo "File,Start Line,End Line,Command,Status,Error Message" > "$CSV_REPORT"
echo "=== OBCLIENT SYNTAX & SUPPORT AUDIT REPORT ===" > "$SUMMARY_LOG"

total_tested=0
total_errors=0

for sql_file in "$SQL_DIR"/*.sql; do
    [ -e "$sql_file" ] || continue
    filename=$(basename "$sql_file")
    echo "Auditing: $filename"

    current_line=0
    stmt_buffer=""
    stmt_start_line=0
    in_plsql=0

    while IFS= read -r line || [ -n "$line" ]; do
        ((current_line++))

        # Trim leading and trailing whitespace
        trimmed=$(echo "$line" | sed 's/^[ \t]*//;s/[ \t]*$//')

        # Skip standalone '/' if buffer is empty
        if [[ -z "$stmt_buffer" && "$trimmed" == "/" ]]; then
            continue
        fi

        # Skip empty lines or pure comments when starting a new buffer
        if [[ -z "$stmt_buffer" ]]; then
            if [[ -z "$trimmed" || "$trimmed" =~ ^-- || "$trimmed" =~ ^/\* ]]; then
                continue
            fi
            stmt_start_line=$current_line
            stmt_buffer="$trimmed"
            
            # Detect PL/SQL block start keywords safely
            lower_first=$(echo "$trimmed" | tr '[:upper:]' '[:lower:]')
            if echo "$lower_first" | grep -qE "^(declare|begin|create[ \t]+(or[ \t]+replace[ \t]+)?(procedure|function|package|trigger|type|body))"; then
                in_plsql=1
            else
                in_plsql=0
            fi
        else
            [[ -n "$trimmed" && ! "$trimmed" =~ ^-- ]] && stmt_buffer="$stmt_buffer $trimmed"
        fi

        lower_buf=$(echo "$stmt_buffer" | tr '[:upper:]' '[:lower:]')

        # Determine statement completion safely
        is_complete=0
        if [[ $in_plsql -eq 1 ]]; then
            # PL/SQL completes on trailing '/' or 'end;' / 'end; /'
            if [[ "$trimmed" == "/" ]] || echo "$lower_buf" | grep -qE "end;[ \t]*/?$"; then
                is_complete=1
                # Clean off trailing slash before running in OBClient
                stmt_buffer=$(echo "$stmt_buffer" | sed -E 's/\/[ \t]*$//')
            fi
        else
            # Standard SQL completes on ';'
            if [[ "$stmt_buffer" == *";" ]]; then
                is_complete=1
            elif [[ "$lower_buf" == set\ * || "$lower_buf" == set$'\t'* ]] && [[ "$lower_buf" != *"="* ]]; then
                # Standalone SQL*Plus SET command without semicolon
                stmt_buffer="${stmt_buffer};"
                is_complete=1
            fi
        fi

        # Execute once statement or PL/SQL block is completely assembled
        if [[ $is_complete -eq 1 ]]; then
            ((total_tested++))
            
            output=$(obclient -h"$OB_HOST" -P"$OB_PORT" -u"$OB_USER" -p"$OB_PASS" -D"$OB_DB" -A -e "$stmt_buffer" 2>&1)
            res=$?

            clean_stmt=$(echo "$stmt_buffer" | tr '\n' ' ' | sed 's/"/'\''/g')

            # 1. Valid syntax, but missing database object or PL/SQL dependency
            if echo "$output" | grep -iqE "$IGNORE_OBJECT_ERRORS"; then
                echo "\"$filename\",$stmt_start_line,$current_line,\"$clean_stmt\",\"OK (Missing DB Object)\",\"\"" >> "$CSV_REPORT"

            # 2. Actual syntax error or unsupported command
            elif [[ $res -ne 0 ]] || echo "$output" | grep -iqE "OBE-|ERROR|SP2-|syntax error|unknown system variable"; then
                ((total_errors++))
                clean_err=$(echo "$output" | tr '\n' ' ' | sed 's/"/'\''/g')

                echo "  ❌ Lines $stmt_start_line-$current_line: ${clean_stmt:0:50}... -> ${clean_err:0:50}..."
                echo "\"$filename\",$stmt_start_line,$current_line,\"$clean_stmt\",\"UNSUPPORTED/ERROR\",\"$clean_err\"" >> "$CSV_REPORT"

                {
                    echo "[$filename : Lines $stmt_start_line-$current_line]"
                    echo "Command: $clean_stmt"
                    echo "Error:   $clean_err"
                    echo "------------------------------------------------------------"
                } >> "$SUMMARY_LOG"
            else
                echo "\"$filename\",$stmt_start_line,$current_line,\"$clean_stmt\",\"OK\",\"\"" >> "$CSV_REPORT"
            fi

            stmt_buffer=""
            in_plsql=0
        fi

    done < "$sql_file"
done

echo ""
echo "Audit finished!"
echo "Total statements tested : $total_tested"
echo "Total errors found      : $total_errors"
echo "Detailed CSV Report     : $CSV_REPORT"
echo "Errors Summary Log      : $SUMMARY_LOG"
