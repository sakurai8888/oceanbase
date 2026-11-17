# OceanBase 4.4.2 SQL review rules

## 1. Scope and defaults

- Target **OceanBase 4.4.2** and distinguish **Oracle mode** from **MySQL mode**.
- Use the tenant mode stated by the user. For the established review workflow
  from which this skill was created, default to **Oracle mode** when no mode is
  stated and disclose that assumption. If the mode would change the finding in
  a new workflow, ask for the mode instead of guessing.
- Check only these items unless the user explicitly requests more:
  1. SQL and PL/SQL syntax.
  2. DDL statement type, object type, required clauses, column definitions,
     datatypes, constraints, defaults, generated/identity columns, partitions,
     table/index options, and documented object-specific options.
  3. SQL function names, signatures, argument counts, and options.
  4. System-package and routine names, overloads, argument counts, argument
     names, defaults, return forms, and options.
  5. Query-hint names, arguments, placement, and documented mode applicability.
  6. EXPLAIN and plan-display syntax and documented format options.
- Do not mark a statement as needing change solely because of business logic,
  data quality, naming style, performance preference, rerun behavior, or a
  possible operational risk. Mention a serious risk separately only when useful,
  without changing the syntax verdict.

## 2. Verdict semantics

Use these values consistently:

- `IsValid = Yes`, `NeedChange = No`: the reviewed items conform to the pinned
  documentation. Object existence, privileges, data, and runtime prerequisites
  are outside the syntax verdict unless explicitly included.
- `IsValid = No`, `NeedChange = Yes`: at least one reviewed item is malformed,
  incompatible with the selected mode, or not documented for the requested
  compatibility contract.
- Do not return the confusing combination `IsValid = Yes` and
  `NeedChange = Yes` for the same reviewed item. Put optional improvements or
  runtime prerequisites in a note and keep `NeedChange = No` when the syntax
  itself requires no change.
- If evidence is insufficient, use `IsValid = Uncertain`, explain exactly what
  the documentation does not establish, and set `NeedChange` according to the
  user's compatibility policy. Do not invent a definitive result.

## 3. Required result format

Return one Markdown table with these columns in this order:

| Statement | IsValid | NeedChange | Position | Change What |
|-----------|---------|------------|----------|-------------|

Follow these rules:

- Identify each statement by number and a short SQL excerpt.
- Use one row per statement when it has no more than one issue.
- Use separate issue rows for multiple unsupported positions in one statement;
  repeat the statement identifier so no issue is lost.
- For a valid statement, use `N/A` in `Position` and `Change What`.
- In `Position`, quote the exact problematic fragment in backticks and then
  highlight the precise token. For example:
  `/*+ INDEX_DESC(o idx_orders_cust_date) */` → **`INDEX_DESC`**.
- For a missing required DDL element, highlight the insertion boundary and name
  the missing element. For example: `CREATE TABLE (` → **missing `table_name`
  between `TABLE` and `(`**.
- In `Change What`, state the concrete required replacement, insertion, or
  removal. Give a corrected statement when useful or requested.
- Do not silently rewrite business logic, predicates, bind values, object names,
  column definitions, constraints, or requested result ordering.

## 4. Official-evidence rules

- Use the bundled references and their pinned OceanBase official links as the
  primary evidence. Do not substitute generic Oracle, MySQL, PostgreSQL, SQL
  Server, or Db2 behavior.
- Distinguish these findings explicitly:
  - **Documented:** a dedicated reference, signature, syntax form, option, or
    official example supports the claim.
  - **Example-only evidence:** an official example contains the token but no
    dedicated interface fully specifies it.
  - **Not documented:** the pinned 4.4.2 inventory does not contain supporting
    documentation. This is not proof about every internal or later build.
  - **Runtime verified:** an actual OceanBase server accepted or rejected the
    statement. Never use this label for static documentation review.
- Match DDL to the correct mode and object-specific page. Do not infer support
  from a similarly named statement for another object or tenant mode.
- Do not infer that an Oracle-chapter hint is also documented for MySQL mode.
  Use the guide's mode field and MySQL evidence links.
- Do not treat outline markers such as `BEGIN_OUTLINE_DATA` and
  `END_OUTLINE_DATA`, placeholders, or arbitrary example tokens as independent
  hint names.
- A hint can be ignored rather than rejected. A statement executing without an
  error does not prove that its hint was valid or applied; inspect the plan.

## 5. Recurring OceanBase 4.4.2 findings

Apply these only after checking the relevant catalog section:

- The documented access-path list includes `INDEX`, `NO_INDEX`, and `INDEX_SS`.
  `INDEX_DESC` and `INDEX_FFS` are absent from that pinned access-path list.
- Do not describe `INDEX` as a semantic equivalent of `INDEX_DESC` or
  `INDEX_FFS`: descending direction and fast-full-scan behavior are different
  requests. Recommend a documented access-path approach and plan verification.
- Replace Oracle-style `EXPLAIN PLAN FOR` with the documented OceanBase form:
  `EXPLAIN [INTO table] [SET STATEMENT_ID = value] dml_statement`.
- `DBMS_XPLAN.DISPLAY` documents the formats `BASIC`, `TYPICAL`, `ALL`, and
  `ADVANCED`; do not assume Oracle's combined `TYPICAL +HINT_REPORT` option is
  valid.
- `DBMS_PARALLEL_EXECUTE` is absent from the documented 4.4.2 package
  inventory. Do not invent its routines or views. Consider documented
  `DBMS_SCHEDULER` or controlled serial/chunked processing according to the
  user's actual requirement.
- Nested `/* ... */` comments are unsupported in OceanBase SQL and PL/SQL.
  Recommend separate block comments or line comments instead.
- For `EXPLAIN INTO` with a dedicated plan table, check plan-table prerequisites
  and session timestamp handling separately from the syntax verdict. The prior
  verified session setting was
  `ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS.FF';`.

## 6. DDL-specific review checklist

Use `ddl-catalog.sql` and perform all applicable checks:

1. **Statement and object:** Identify CREATE, ALTER, DROP, TRUNCATE, RENAME, or
   COMMENT and the exact object type. Check required names and clauses, IF
   EXISTS/IF NOT EXISTS placement, and mode-specific alternatives.
2. **CREATE TABLE:** Check every column name and datatype; datatype arguments;
   NULL/NOT NULL; DEFAULT expressions; AUTO_INCREMENT in MySQL mode; identity
   and generated-column forms in the relevant mode; virtual/stored forms;
   inline and table-level PRIMARY KEY, UNIQUE, FOREIGN KEY, and CHECK
   constraints; and COMMENT clauses.
3. **Table organization:** Check TEMPORARY or GLOBAL TEMPORARY, CREATE TABLE AS
   SELECT, CREATE TABLE LIKE, external-table clauses, tablegroups, tablespaces,
   physical attributes, compression, parallel options, and other table options
   against the selected page. Do not assume an option is valid merely because
   another OceanBase mode or another database accepts it.
4. **Partitioning:** Check partition type, partition count, expressions, key or
   column lists, subpartitioning, partition names, values, and table-level
   placement against the documented partition clauses.
5. **Indexes:** Check UNIQUE/FULLTEXT/other documented index types, key parts,
   prefix lengths or expressions where applicable, ASC/DESC, USING, GLOBAL or
   LOCAL, parser and index options, and the mode-specific DROP INDEX form.
6. **ALTER TABLE and related objects:** Check each action separately, including
   ADD, MODIFY, CHANGE, DROP, RENAME, constraint actions, partition actions, and
   table-option changes. A valid action does not make every combination or every
   list of actions valid.
7. **Views and materialized objects:** Check view SELECT structure and options;
   materialized-view/log syntax; refresh method, timing, schedule, and ON
   COMMIT/ON DEMAND options; and the applicable mode's restrictions.
8. **Sequences, synonyms, links, and other objects:** Check sequence bounds,
   INCREMENT BY, START WITH, MINVALUE/MAXVALUE, CACHE, CYCLE, and ORDER options;
   PUBLIC and object-name rules for synonyms; and the object-specific clauses
   for database links, directories, locations, outlines, tablegroups,
   tablespaces, users, roles, and administrative DDL when requested.
9. **TRUNCATE, RENAME, COMMENT:** Check the required object type, target names,
   option placement, and mode-specific syntax rather than treating these as
   interchangeable aliases.
10. **Verdict boundary:** Keep object existence, duplicate names, privileges,
    available storage, and other runtime prerequisites separate from syntax.
    Highlight every unsupported or malformed clause individually and preserve
    all valid clauses in a corrected version.

## 7. Safety and runtime boundaries

- Never execute an entire bundled catalog. It contains syntax diagrams,
  administrative examples, DDL, DML, scheduler, security, file/network, and
  other state-changing operations.
- Never execute user-supplied INSERT, UPDATE, DELETE, REPLACE, MERGE, DDL, or
  package calls merely to perform a compatibility review.
- DDL can create, alter, drop, rename, truncate, or expose objects and can have
  administrative or security effects. Require explicit authorization and an
  isolated test environment for any requested live DDL validation.
- If live testing is explicitly requested, use an isolated OceanBase 4.4.2
  tenant/schema, least privileges, and individual statements. Prefer parsing or
  `EXPLAIN` over execution and preserve the ability to roll back test DML.
- Report static review and live execution as separate evidence layers.
