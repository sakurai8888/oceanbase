---
name: file-naming
description: File and directory naming conventions for this OceanBase PoC repository — where files go and how to name them
type: prompt
whenToUse: When the user asks me to create, rename, move, or organize files or directories in this repository
---

Follow these naming and placement rules for any file you create, rename, or move in
this repository.

## Directory placement

| Content | Location |
| --- | --- |
| Documentation, test case lists, notes | `docs/` |
| OceanBase SQL scripts | `scripts/oceanbase/` |
| Linux/shell scripts and snippets | `scripts/linux/` |
| PoC test scripts grouped by test case ID | `poc_scripts/poc_<X>_<Y>_<Z>/` |
| Packed toolkits, split archives, original bundles | `archives/` |

Do not drop loose files in the repository root. The root only holds `README.md`,
the directory folders, and meta files (`.git`, etc.).

## Naming rules

- Always use a file extension that matches the content: `.sql`, `.md`, `.sh`,
  `.txt`. Never create extensionless files like `OceanBase_TDE` or `pocsql`.
- Use lowercase `snake_case` for names: `oceanbase_tde.sql`, `linux_commands.md`.
- Keep names descriptive of the content, not of the action taken on them —
  avoid names like `*_to_upload.sql` for new files.
- README files are named exactly `README.md` (watch the typo `RAEDME.md` —
  it must not be reintroduced).
- PoC script folders follow the test case numbering in
  `docs/test_case_lists.txt`: `poc_<section>_<subsection>_<item>`,
  e.g. `poc_5_2_1` for test case 5.2.1 (data import/export).
- Inside a PoC folder, use the established filenames: `create_table.sql`,
  `load_data.sql`, `verify_table.sql`, `genfile.sh`, `test_commands.txt`.
- Split archives keep their part suffixes (`.zip.001`, `.zip.002`, ...) and
  live untouched in `archives/`.

## Known quirks to preserve in docs

- The `.tar.gz` files in `archives/` are actually plain uncompressed tar
  archives — extract with `tar xf <file>` (no `-z`).
- The split zip is reassembled with
  `cat db_poc_scripts_131.zip.00* > db_poc_scripts_131.zip` before `unzip`.

## After renaming or moving files

- Update `README.md` so the structure diagram and descriptions stay accurate.
- Verify no other file references the old path.
