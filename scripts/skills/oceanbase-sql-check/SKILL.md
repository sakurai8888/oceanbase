---
name: oceanbase-sql-check
description: >-
  Review SQL compatibility against the pinned OceanBase 4.4.2 official
  documentation in Oracle or MySQL mode. Use for SELECT, INSERT, UPDATE,
  DELETE, REPLACE, MERGE, DDL statements such as CREATE, ALTER, DROP, TRUNCATE,
  RENAME, and COMMENT, query hints, SQL functions, PL/SQL system packages,
  routine argument counts, argument names, options, EXPLAIN, and requests to
  identify or correct unsupported syntax. Trigger for "is this valid in
  OceanBase", "check this SQL", "check this DDL", "CREATE TABLE in OceanBase",
  "OceanBase Oracle mode", "is this hint supported", "check this package call",
  and similar compatibility requests.
---

# OceanBase SQL Compatibility Checker

Review statements against the bundled OceanBase 4.4.2 reference catalogs.
Base compatibility claims on the official documentation, not generic Oracle or
MySQL behavior. Perform static documentation review unless live-server
execution is explicitly available and separately reported.

## Efficient retrieval — mandatory

Minimize reading and response time. Follow these rules for every request:

1. **Never read an entire reference catalog.** Do not open a whole SQL catalog
   or the complete hint guide to locate one feature.
2. Read `references/review-rules.md` once for the current review task and reuse
   it for all statements in that task. Read `official-sources.md` only when
   source, version, or coverage claims require it.
3. Select one reference key from the routing table in the workflow. Always pass
   `--reference`; do not search all catalogs when the feature type is known.
4. Search the most specific token first: the exact hint, package routine,
   function, DDL object plus statement, clause, or option. Start with
   `--max-results 3 --context 2`. Increase context only when the match does not
   contain enough evidence.
5. If the narrow match and its context already establish the required syntax,
   option, restriction, and source, stop there. Otherwise extract only the
   numbered section with `--section-id`, or only a hint heading with
   `--heading`. Do not read surrounding pages or the whole catalog.
6. Reuse an extracted section for all related clauses in the user's statement.
   Do not repeat identical searches or reload evidence already present.
7. Stop searching as soon as the mode, syntax, option, restrictions, and source
   needed for the verdict are established. More reading is not required for a
   complete source inventory when answering one compatibility question.
8. If a search returns no match, try at most two reasonable synonyms or related
   terms in the selected reference. Only then consider a second relevant
   reference. Do not respond to a no-match search by reading the whole file.
9. Use whole-catalog coverage claims only when the user explicitly requests an
   inventory or audit; ordinary validity questions need targeted evidence only.

## Required workflow

1. Read [references/review-rules.md](references/review-rules.md) for the review
   task. Apply its scope, result semantics, evidence wording, and safety rules.
2. Identify the OceanBase version, tenant mode, statement type, DDL object type,
   and every function, package routine, hint, clause, and option that needs
   checking. Follow the mode-default rule in the review rules when the user
   omits the mode.
3. Read [references/official-sources.md](references/official-sources.md) only
   when making source, coverage, version, or evidence-strength claims.
4. Route the request to one reference before searching:
   - SELECT, functions, expressions, conversion: `--reference select`
   - INSERT, UPDATE, DELETE, REPLACE, MERGE: `--reference dml`
   - CREATE, ALTER, DROP, TRUNCATE, RENAME, COMMENT and other documented DDL:
     `--reference ddl`
   - `DBMS_*`, `UTL_*`, `SA_*`, `ODCICONST`, `ANYDATA`, `XMLType`:
     `--reference packages`
   - Query hints: `--reference hints`
5. Search narrowly, then extract only the relevant section. Check its mode,
   syntax, object type, parameter or column definitions, datatypes,
   constraints, defaults, options, restrictions, and examples as applicable.
   For DDL, check each ALTER action and each table, partition, index, or
   materialized-view option separately.
6. Compare each statement with the documented evidence. Check only syntax,
   DDL structure and options, functions, packages, argument counts, argument
   names, options, and hints unless the user explicitly expands the scope.
7. Return the required table from the review rules. Highlight the exact
   problematic token, clause, option, or missing element in `Position`; do not
   merely identify the statement or line.
8. Provide corrected SQL when requested or when it clarifies the required
   change. Preserve the user's business logic, object names, column definitions,
   constraints, and intended behavior. Distinguish a documented replacement
   from a semantic equivalent.
9. Consult [references/validation-examples.md](references/validation-examples.md)
   only for a recurring finding or output-format calibration; do not read it for
   every request.

## Search and extract examples

Run the bundled helper from the skill directory. It uses only the Python
standard library and searches literal text case-insensitively by default.

```bash
# Initial narrow search: return at most three matches with little context.
python3 scripts/search_reference.py INDEX_SS --reference hints --max-results 3 --context 2

# Extract only the INDEX_SS hint section instead of reading the hint guide.
python3 scripts/search_reference.py --heading INDEX_SS --reference hints

# Locate the Oracle CREATE TABLE page's section ID.
python3 scripts/search_reference.py "Oracle mode | CREATE TABLE" --reference ddl --max-results 1 --context 0

# Extract only that page (the current pinned catalog uses DDL-088).
python3 scripts/search_reference.py --section-id DDL-088 --reference ddl

# Locate a specific DDL option without reading the full CREATE TABLE page.
python3 scripts/search_reference.py "GENERATED BY DEFAULT AS IDENTITY" --reference ddl --max-results 3 --context 3

# Find a package example and its section ID.
python3 scripts/search_reference.py DBMS_XPLAN.DISPLAY --reference packages --max-results 3 --context 2

# Extract only one identified package section.
python3 scripts/search_reference.py --section-id C01-001 --reference packages

# List reference keys without opening any reference.
python3 scripts/search_reference.py --list
```

Use `--regex` for a regular expression, `--case-sensitive` for exact case, and
`--max-section-lines` to cap extracted output. Repeatable `--reference` options
are available for searches, but section extraction requires exactly one
reference. Avoid `--reference all` unless the feature type is genuinely unknown.

## Evidence and correction rules

- Cite the pinned official source links already preserved in the extracted
  section or catalog.
- Say **documented** only when the pinned reference explicitly supports the
  interface or behavior.
- Say **example-only evidence** when a token appears in an official example
  without a dedicated interface definition.
- Say **not documented in the pinned 4.4.2 reference** rather than claiming
  that absence from documentation proves every runtime build must reject it.
- Never infer that a DDL form documented for one tenant mode is valid in the
  other. Match the statement to the mode-specific page and object type.
- Treat malformed, unsupported, or conflicting hints carefully: OceanBase may
  ignore a hint instead of raising an error. Hint acceptance does not prove
  that the requested plan was used.
- Never invent a package, routine, parameter, hint, DDL clause, format option,
  or source.
- Never execute a complete catalog or a user's DML or DDL as part of the review.
- Do not describe static review as live execution. Recommend an isolated
  OceanBase 4.4.2 test when runtime confirmation is needed; use `EXPLAIN` for
  supported DML plan checks rather than executing DDL.

## Reference files

- [Review rules](references/review-rules.md): mandatory checking and output
  contract.
- [Official sources](references/official-sources.md): pinned revision,
  provenance, coverage, and evidence boundaries; load only when needed.
- [SELECT catalog](references/select-catalog.sql): documented SELECT forms,
  functions, expressions, conversion, hints, and curated combinations.
- [DML catalog](references/dml-catalog.sql): INSERT, UPDATE, DELETE, REPLACE,
  MERGE, related functions, hints, and expressions.
- [DDL catalog](references/ddl-catalog.sql): 128 official MySQL/Oracle pages
  covering CREATE, ALTER, DROP, TRUNCATE, RENAME, COMMENT, and related DDL.
- [System-package catalog](references/system-packages-catalog.sql): documented
  package signatures, overloads, parameters, options, and restrictions.
- [Query-hint guide](references/query-hints.md): complete 137-entry guide with
  mode applicability, syntax, behavior, examples, and source links.
- [Validation examples](references/validation-examples.md): representative
  findings and expected table rows; load only for recurring cases.

The catalogs are reference material, not deployment scripts. Search and extract
targeted sections for review; test only individual examples in an isolated
environment when execution is needed.
