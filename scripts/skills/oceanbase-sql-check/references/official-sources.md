# Official sources and coverage

## Pinned source

All five large catalogs in this skill were generated from the same official
OceanBase documentation revision:

- Repository: https://github.com/oceanbase/oceanbase-doc
- Branch: `V4.4.2`
- Commit: `017c8d35a015afa04ce1e1ce4b95675e3223c878`
- Pinned tree:
  https://github.com/oceanbase/oceanbase-doc/tree/017c8d35a015afa04ce1e1ce4b95675e3223c878

Use the per-section links in the catalogs to reach the exact official page.
Do not silently mix another OceanBase version into a 4.4.2 finding.

## Bundled reference provenance

| Bundled file | Source deliverable and scope |
|--------------|------------------------------|
| `select-catalog.sql` | `OceanBase_4.4.2_SELECT_Complete_Catalog.sql`: source-linked SELECT forms, MySQL/Oracle function inventories, syntax blocks, official examples, conversion rules, hints, and curated combinations. |
| `dml-catalog.sql` | `OceanBase_4.4.2_INSERT_UPDATE_DELETE_Complete_Catalog.sql`: INSERT, UPDATE, DELETE, REPLACE, MERGE, related expressions, functions, hints, conversion rules, and curated combinations. |
| `ddl-catalog.sql` | New DDL reference generated from the same pinned archive: all 68 unique English pages in the official Oracle-mode DDL chapter plus 60 English MySQL-mode statement pages selected by CREATE, ALTER, DROP, TRUNCATE, RENAME, or COMMENT prefixes. Each of the 128 pages has a mode, title, and pinned official source link; every catalog line is a SQL comment. |
| `system-packages-catalog.sql` | `OceanBase_4.4.2_System_Packages_Complete_Catalog.sql`: documented MySQL and Oracle PL system-package pages plus the Oracle label-security package tree; signatures, overloads, parameters, options, defaults, restrictions, and examples. |
| `query-hints.md` | `OceanBase_4.4.2_Query_Hints_Complete_Guide.md`: 137 unique entries reconciled against 18 dedicated hint pages, shared optimizer guidance, and additional official-example evidence. |

The smaller `review-rules.md` and `validation-examples.md` files distill the
established review decisions from the same project. They do not replace the
full catalogs or their official links.

## Coverage boundaries

- SQL expressions, subqueries, functions, CTEs, windows, set operations, hints,
  and DML compose recursively. The catalogs provide finite, auditable source
  coverage and composition guidance; they cannot enumerate infinite legal
  combinations.
- DDL coverage follows the complete dedicated Oracle DDL chapter and the
  declared MySQL statement-name selection. Its 128 pages include tables,
  external tables, indexes, views, materialized views/logs, sequences, synonyms,
  databases/database links, tablegroups, tablespaces, outlines, user/role and
  security objects, and related statements documented in those inventories.
- Package coverage means every page in the declared official documentation
  inventory, not every undocumented internal symbol in an OceanBase binary.
- Query-hint coverage includes dedicated reference entries, relevant shared
  optimizer-guide entries, and clearly labeled additional official evidence.
  Placeholder tokens and outline structural markers are not counted as
  independent hints.
- Static artifact verification is not live-server execution. The bundled
  catalogs were not executed as complete scripts against OceanBase.
- Runtime behavior can also depend on the exact 4.4.2 BP, tenant mode, server
  variables, edition/options, object definitions, privileges, and data.

## How to phrase findings

Prefer precise wording:

- “The pinned OceanBase 4.4.2 documentation specifies …”
- “This call matches the documented signature …”
- “This DDL clause matches the selected mode and object-specific reference …”
- “The pinned documentation provides example-only evidence for …”
- “This name is not documented in the pinned 4.4.2 inventory …”
- “Static documentation review cannot confirm this runtime behavior; test it in
  an isolated OceanBase 4.4.2 environment.”

Avoid unsupported absolutes such as “every OceanBase build will reject this”
when the evidence is documentation absence. Conversely, do not claim that a
statement was successfully executed when only documentation was reviewed.

## Updating the source

Keep all five catalogs on the same pinned revision. For another OceanBase
version, regenerate or revalidate the references as a unit, update the source
identity, and rerun coverage checks. Do not overwrite a verified catalog with
scattered snippets from a different version.
