#!/usr/bin/env python3
"""
convert_jobs.py — best-effort Oracle -> OceanBase DBMS_SCHEDULER job converter.

Reads an Oracle scheduler dump (.sql) and emits an OceanBase 4.4.2 compatible
script, applying rules R1-R8 and rewriting illegal repeat_interval expressions.

This is a HELPER, not an oracle (pun intended). Dump files are highly regular,
so regex extraction works well, but ALWAYS review the output. In particular:

  * argument values are never invented — jobs with number_of_arguments > 0 are
    emitted with placeholders and reported as ACTION REQUIRED
  * time zone regions not in TZ_MAP are flagged, not guessed
  * repeat_interval rewrites are reported so they can be reviewed

Usage:
    python3 convert_jobs.py input.sql -o output.sql [--version 4.4.2]
    python3 convert_jobs.py input.sql --report-only
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass, field
from typing import Optional

# --------------------------------------------------------------------------
# Time zone regions -> fixed UTC offset.
# Only fixed-offset regions belong here. DST regions cannot be represented
# as a static offset and are deliberately absent so they get flagged.
# --------------------------------------------------------------------------
TZ_MAP = {
    "ASIA/HONG_KONG": "+08:00",
    "ASIA/SHANGHAI": "+08:00",
    "ASIA/CHONGQING": "+08:00",
    "ASIA/SINGAPORE": "+08:00",
    "ASIA/TAIPEI": "+08:00",
    "ASIA/MANILA": "+08:00",
    "ASIA/KUALA_LUMPUR": "+08:00",
    "ASIA/TOKYO": "+09:00",
    "ASIA/SEOUL": "+09:00",
    "ASIA/BANGKOK": "+07:00",
    "ASIA/JAKARTA": "+07:00",
    "ASIA/KOLKATA": "+05:30",
    "ASIA/DUBAI": "+04:00",
    "UTC": "+00:00",
    "GMT": "+00:00",
}

# FREQ -> set of BY* clauses that OceanBase permits
FREQ_ALLOWED = {
    "YEARLY": {"BYMONTH", "BYMONTHDAY", "BYYEARDAY", "BYHOUR", "BYMINUTE", "BYSECOND"},
    "MONTHLY": {"BYMONTHDAY", "BYHOUR", "BYMINUTE", "BYSECOND"},
    "WEEKLY": {"BYDAY", "BYHOUR", "BYMINUTE", "BYSECOND"},
    "DAILY": {"BYHOUR", "BYMINUTE", "BYSECOND"},
    "HOURLY": {"BYMINUTE", "BYSECOND"},
    "MINUTELY": {"BYSECOND"},
    "SECONDLY": set(),
}


@dataclass
class Job:
    name: str = ""
    action: str = ""
    nargs: int = 0
    start_date: str = ""
    repeat_interval: str = ""
    end_date: str = "NULL"
    job_class: str = "DEFAULT_JOB_CLASS"
    enabled: bool = False
    auto_drop: bool = True
    comments: str = "NULL"
    had_enable: bool = False
    issues: list[str] = field(default_factory=list)
    rewrites: list[str] = field(default_factory=list)


# --------------------------------------------------------------------------
# Extraction
# --------------------------------------------------------------------------
def split_blocks(text: str) -> list[str]:
    """Split a dump into BEGIN ... END; / blocks."""
    return re.findall(r"BEGIN\b.*?\bEND\s*;\s*/", text, re.S | re.I)


def parse_job(block: str) -> Optional[Job]:
    if not re.search(r"create_job\s*\(", block, re.I):
        return None

    job = Job()

    m = re.search(r"create_job\s*\(\s*'\"?([A-Za-z0-9_$#]+)\"?'", block, re.I)
    if not m:
        return None
    job.name = m.group(1).upper()

    m = re.search(r"job_action\s*=>\s*'([^']+)'", block, re.I)
    if m:
        job.action = m.group(1)

    m = re.search(r"number_of_arguments\s*=>\s*(\d+)", block, re.I)
    if m:
        job.nargs = int(m.group(1))

    m = re.search(r"start_date\s*=>\s*TO_TIMESTAMP_TZ\s*\(\s*'([^']+)'", block, re.I | re.S)
    if m:
        job.start_date = m.group(1)

    m = re.search(r"repeat_interval\s*=>\s*'([^']+)'", block, re.I | re.S)
    if m:
        job.repeat_interval = m.group(1)

    m = re.search(r"job_class\s*=>\s*'\"?([A-Za-z0-9_$#]+)\"?'", block, re.I)
    if m:
        job.job_class = m.group(1)

    m = re.search(r"enabled\s*=>\s*(TRUE|FALSE)", block, re.I)
    if m:
        job.enabled = m.group(1).upper() == "TRUE"

    m = re.search(r"auto_drop\s*=>\s*(TRUE|FALSE)", block, re.I)
    if m:
        job.auto_drop = m.group(1).upper() == "TRUE"

    m = re.search(r"comments\s*=>\s*(NULL|'((?:[^']|'')*)')", block, re.I | re.S)
    if m and m.group(1).upper() != "NULL":
        job.comments = "'" + m.group(2) + "'"

    job.had_enable = bool(re.search(r"dbms_scheduler\.enable\s*\(", block, re.I))
    return job


# --------------------------------------------------------------------------
# Transformations
# --------------------------------------------------------------------------
def convert_start_date(raw: str, job: Job) -> str:
    """R2: region name -> numeric offset; drop the NLS_DATE_LANGUAGE parameter."""
    m = re.match(r"^(.*?)\s+([A-Za-z]+/[A-Za-z_]+|[A-Za-z]+)$", raw.strip())
    if not m:
        job.issues.append(f"start_date could not be parsed: {raw!r}")
        return raw

    stamp, region = m.group(1), m.group(2).upper()
    offset = TZ_MAP.get(region)
    if offset is None:
        job.issues.append(
            f"time zone region {region!r} not in TZ_MAP (possible DST region) — "
            f"offset must be supplied manually"
        )
        offset = "<OFFSET>"
    else:
        job.rewrites.append(f"start_date: {region} -> {offset}")

    return f"{stamp} {offset}"


def rewrite_interval(expr: str, job: Job, version: str) -> str:
    """Validate and repair FREQ/BY* pairing for OceanBase."""
    if not expr:
        job.issues.append("repeat_interval is empty — OceanBase raises an error on NULL")
        return expr

    parts = [p.strip() for p in expr.split(";") if p.strip()]
    kv: dict[str, str] = {}
    order: list[str] = []
    for p in parts:
        if "=" not in p:
            job.issues.append(f"repeat_interval fragment without '=': {p!r}")
            continue
        k, v = p.split("=", 1)
        k = k.strip().upper()
        kv[k] = v.strip()
        order.append(k)

    freq = kv.get("FREQ", "").upper()
    if freq not in FREQ_ALLOWED:
        job.issues.append(f"unknown FREQ {freq!r} in repeat_interval")
        return expr

    by_keys = [k for k in kv if k.startswith("BY")]

    # 4.2.x: only FREQ + INTERVAL are supported
    if version.startswith("4.2"):
        if by_keys:
            job.issues.append(
                f"OB {version} does not support {','.join(by_keys)} — "
                f"encode the time-of-day in start_date and keep FREQ+INTERVAL only"
            )
        return ";".join(f"{k}={kv[k]}" for k in ("FREQ", "INTERVAL") if k in kv)

    # Negative BYDAY is rejected
    if "BYDAY" in kv and "-" in kv["BYDAY"]:
        job.issues.append(
            f"negative BYDAY ({kv['BYDAY']}) is not supported (OB_PASSER_ERROR); "
            f"no equivalent exists — escalate to the business"
        )

    # Re-base FREQ when the BY* clauses are not permitted for it
    if freq == "HOURLY" and "BYDAY" in kv:
        kv["FREQ"] = "WEEKLY"
        job.rewrites.append("repeat_interval: FREQ=HOURLY+BYDAY -> FREQ=WEEKLY")
    elif freq == "HOURLY" and "BYHOUR" in kv:
        kv["FREQ"] = "DAILY"
        job.rewrites.append("repeat_interval: FREQ=HOURLY+BYHOUR -> FREQ=DAILY")
    elif freq == "DAILY" and "BYDAY" in kv:
        kv["FREQ"] = "WEEKLY"
        job.rewrites.append("repeat_interval: FREQ=DAILY+BYDAY -> FREQ=WEEKLY")

    # Re-validate after the rewrite
    freq = kv["FREQ"]
    illegal = [k for k in kv if k.startswith("BY") and k not in FREQ_ALLOWED[freq]]
    if illegal:
        job.issues.append(
            f"repeat_interval still has {','.join(illegal)} which FREQ={freq} does not permit"
        )

    # INTERVAL must precede BY*
    ordered = ["FREQ"]
    if "INTERVAL" in kv:
        ordered.append("INTERVAL")
    ordered += [k for k in kv if k.startswith("BY")]
    ordered += [k for k in kv if k not in ordered]
    if "INTERVAL" in order and by_keys:
        first_by = min(order.index(k) for k in by_keys if k in order)
        if order.index("INTERVAL") > first_by:
            job.rewrites.append("repeat_interval: INTERVAL moved before BY* clauses")

    return ";".join(f"{k}={kv[k]}" for k in ordered if k in kv)


# --------------------------------------------------------------------------
# Emission
# --------------------------------------------------------------------------
def emit_job(job: Job, idx: int) -> str:
    lines = [f"-- {idx:02d}  {job.name}", "BEGIN", "    DBMS_SCHEDULER.CREATE_JOB("]
    pad = "        "
    lines.append(f"{pad}job_name        => '{job.name}',")
    lines.append(f"{pad}job_type        => 'STORED_PROCEDURE',")
    lines.append(f"{pad}job_action      => '{job.action}',")
    if job.nargs > 0:
        lines.append(f"{pad}number_of_argument => {job.nargs},")
    lines.append(
        f"{pad}start_date      => TO_TIMESTAMP_TZ('{job.start_date}',"
        f"'DD-MON-RRRR HH.MI.SSXFF AM TZR'),"
    )
    lines.append(f"{pad}repeat_interval => '{job.repeat_interval}',")
    lines.append(f"{pad}end_date        => {job.end_date},")
    lines.append(f"{pad}enabled         => FALSE,")
    lines.append(f"{pad}auto_drop       => {'TRUE' if job.auto_drop else 'FALSE'},")
    lines.append(f"{pad}job_class       => '{job.job_class}',")
    lines.append(f"{pad}comments        => {job.comments}")
    lines.append("    );")
    lines.append("END;")
    lines.append("/")
    return "\n".join(lines)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("input")
    ap.add_argument("-o", "--output")
    ap.add_argument("--version", default="4.4.2", help="target OceanBase version")
    ap.add_argument("--report-only", action="store_true")
    args = ap.parse_args()

    with open(args.input, encoding="utf-8", errors="replace") as fh:
        text = fh.read()

    jobs: list[Job] = []
    for block in split_blocks(text):
        job = parse_job(block)
        if job is None:
            continue
        job.start_date = convert_start_date(job.start_date, job)
        job.repeat_interval = rewrite_interval(job.repeat_interval, job, args.version)
        jobs.append(job)

    if not jobs:
        print("No CREATE_JOB blocks found.", file=sys.stderr)
        return 1

    # ---- report -----------------------------------------------------------
    print(f"Parsed {len(jobs)} CREATE_JOB block(s).\n")

    with_args = [j for j in jobs if j.nargs > 0]
    no_enable = [j for j in jobs if not j.had_enable]

    print(f"Jobs with arguments : {len(with_args)}")
    for j in with_args:
        print(f"  - {j.name} ({j.nargs} arg)")
    print(f"Jobs never ENABLEd  : {len(no_enable)}")
    for j in no_enable:
        print(f"  - {j.name}")

    flagged = [j for j in jobs if j.issues]
    if flagged:
        print("\nACTION REQUIRED:")
        for j in flagged:
            for issue in j.issues:
                print(f"  [{j.name}] {issue}")

    rewritten = [j for j in jobs if j.rewrites]
    if rewritten:
        print("\nAUTO-REWRITTEN (review these):")
        for j in rewritten:
            for r in j.rewrites:
                print(f"  [{j.name}] {r}")

    if args.report_only:
        return 0

    # ---- emit -------------------------------------------------------------
    out = [
        "-- =====================================================================",
        f"--  Converted from: {args.input}",
        f"--  Target: OceanBase {args.version} (Oracle Mode)",
        f"--  Jobs: {len(jobs)}   Generated by convert_jobs.py",
        "--  REVIEW REQUIRED: argument values and flagged items are not resolved.",
        "-- =====================================================================",
        "",
    ]
    for i, job in enumerate(jobs, 1):
        out.append(emit_job(job, i))
        out.append("")

    out.append("COMMIT;")
    out.append("")

    if with_args:
        out.append("-- Arguments required for the jobs below (values NOT supplied):")
        for j in with_args:
            out.append(f"--   {j.name}: {j.nargs} argument(s)")
        out.append("-- Collect from the source database:")
        out.append("--   SELECT job_name, argument_position, argument_name, value")
        out.append("--     FROM dba_scheduler_job_args")
        out.append("--    WHERE owner = '<OWNER>'")
        out.append("--    ORDER BY job_name, argument_position;")
        out.append("")

    body = "\n".join(out)
    if args.output:
        with open(args.output, "w", encoding="utf-8") as fh:
            fh.write(body)
        print(f"\nWritten to {args.output}")
    else:
        print("\n" + body)

    return 0


if __name__ == "__main__":
    sys.exit(main())