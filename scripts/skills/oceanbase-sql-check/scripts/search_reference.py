#!/usr/bin/env python3
"""Search or extract small, relevant portions of the OceanBase references."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

SKILL_ROOT = Path(__file__).resolve().parents[1]
REFERENCE_ROOT = SKILL_ROOT / "references"
REFERENCES = {
    "rules": REFERENCE_ROOT / "review-rules.md",
    "sources": REFERENCE_ROOT / "official-sources.md",
    "select": REFERENCE_ROOT / "select-catalog.sql",
    "dml": REFERENCE_ROOT / "dml-catalog.sql",
    "ddl": REFERENCE_ROOT / "ddl-catalog.sql",
    "packages": REFERENCE_ROOT / "system-packages-catalog.sql",
    "hints": REFERENCE_ROOT / "query-hints.md",
    "examples": REFERENCE_ROOT / "validation-examples.md",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Search bundled OceanBase 4.4.2 references or extract one section. "
            "Multiple literal search terms must all occur on the same line."
        )
    )
    parser.add_argument("terms", nargs="*", help="Literal terms or one regular expression")
    parser.add_argument(
        "--reference",
        action="append",
        choices=[*REFERENCES, "all"],
        help="Reference key; repeat for searches across selected files (default: all)",
    )
    parser.add_argument("--context", type=int, default=2, help="Context lines around matches (default: 2)")
    parser.add_argument("--max-results", type=int, default=5, help="Maximum matches (default: 5)")
    parser.add_argument("--regex", action="store_true", help="Interpret joined search terms as a regular expression")
    parser.add_argument("--case-sensitive", action="store_true", help="Use case-sensitive matching")
    parser.add_argument("--line-width", type=int, default=500, help="Clip displayed search lines (default: 500)")
    parser.add_argument("--list", action="store_true", help="List reference keys and exit")
    extraction = parser.add_mutually_exclusive_group()
    extraction.add_argument("--section-id", help="Extract one SQL-catalog section, for example DDL-088 or C01-001")
    extraction.add_argument("--heading", help="Extract one Markdown heading section, for example INDEX_SS")
    parser.add_argument(
        "--max-section-lines",
        type=int,
        default=1000,
        help="Safety cap for extracted sections (default: 1000)",
    )
    return parser.parse_args()


def selected_files(keys: list[str] | None) -> list[tuple[str, Path]]:
    if not keys or "all" in keys:
        return list(REFERENCES.items())
    return [(key, REFERENCES[key]) for key in dict.fromkeys(keys)]


def clipped(text: str, width: int) -> str:
    return text if len(text) <= width else text[: max(1, width - 1)] + "…"


def one_extraction_file(args: argparse.Namespace) -> tuple[str, Path]:
    keys = args.reference or []
    if len(keys) != 1 or keys[0] == "all":
        raise ValueError("Section extraction requires exactly one explicit --reference key.")
    if args.terms:
        raise ValueError("Do not combine search terms with --section-id or --heading.")
    key = keys[0]
    path = REFERENCES[key]
    if not path.is_file():
        raise ValueError(f"Reference does not exist: {path}")
    return key, path


def print_section(key: str, path: Path, start: int, stop: int, lines: list[str], cap: int) -> int:
    available = stop - start
    shown = min(available, cap)
    print(f"### {key}: references/{path.name}:{start + 1}-{start + shown}")
    for line in lines[start:start + shown]:
        print(line)
    if shown < available:
        print(f"\n[Truncated: {available - shown} more lines. Increase --max-section-lines or search within this section.]")
    print(f"\nExtracted {shown} line(s); full catalog contains {len(lines)} lines.")
    return 0


def extract_section_id(args: argparse.Namespace) -> int:
    key, path = one_extraction_file(args)
    lines = path.read_text(encoding="utf-8").splitlines()
    wanted = args.section_id.upper()
    marker = re.compile(rf"^--\s+\[{re.escape(wanted)}\](?:\s|$)", re.IGNORECASE)
    starts = [i for i, line in enumerate(lines) if marker.search(line)]
    if not starts:
        print(f"Section ID not found: {wanted}", file=sys.stderr)
        return 1
    # A section ID can also occur in the catalog TOC; the actual section is last.
    start = starts[-1]

    if "-" in wanted:
        next_marker = re.compile(r"^--\s+\[[A-Z][A-Z0-9-]*\d+\](?:\s|$)", re.IGNORECASE)
    else:
        next_marker = re.compile(r"^--\s+\[[A-Z][A-Z0-9]*\d+\](?:\s|$)", re.IGNORECASE)
    stop = next((i for i in range(start + 1, len(lines)) if next_marker.search(lines[i])), len(lines))
    return print_section(key, path, start, stop, lines, args.max_section_lines)


def extract_heading(args: argparse.Namespace) -> int:
    key, path = one_extraction_file(args)
    lines = path.read_text(encoding="utf-8").splitlines()
    wanted = args.heading.strip().strip("`").casefold()
    start = None
    level = 0
    for i, line in enumerate(lines):
        match = re.match(r"^(#{1,6})\s+(.+?)\s*$", line)
        if not match:
            continue
        title = match.group(2).strip().strip("`").casefold()
        if title == wanted or title == f"{wanted} hint":
            start = i
            level = len(match.group(1))
            break
    if start is None:
        print(f"Heading not found: {args.heading}", file=sys.stderr)
        return 1

    stop = len(lines)
    for i in range(start + 1, len(lines)):
        match = re.match(r"^(#{1,6})\s+", lines[i])
        if match and len(match.group(1)) <= level:
            stop = i
            break
    return print_section(key, path, start, stop, lines, args.max_section_lines)


def main() -> int:
    args = parse_args()

    if args.list:
        for key, path in REFERENCES.items():
            status = f"{path.stat().st_size:,} bytes" if path.is_file() else "MISSING"
            print(f"{key:8} references/{path.name} ({status})")
        return 0
    if not 1 <= args.max_section_lines <= 2000:
        print("--max-section-lines must be between 1 and 2000.", file=sys.stderr)
        return 2
    try:
        if args.section_id:
            return extract_section_id(args)
        if args.heading:
            return extract_heading(args)
    except ValueError as exc:
        print(str(exc), file=sys.stderr)
        return 2

    if not args.terms:
        print("Provide search terms, --section-id, --heading, or --list.", file=sys.stderr)
        return 2
    if not 0 <= args.context <= 20:
        print("--context must be between 0 and 20.", file=sys.stderr)
        return 2
    if not 1 <= args.max_results <= 200:
        print("--max-results must be between 1 and 200.", file=sys.stderr)
        return 2
    if args.line_width < 40:
        print("--line-width must be at least 40.", file=sys.stderr)
        return 2

    flags = 0 if args.case_sensitive else re.IGNORECASE
    pattern = None
    folded_terms: list[str] = []
    if args.regex:
        try:
            pattern = re.compile(" ".join(args.terms), flags)
        except re.error as exc:
            print(f"Invalid regular expression: {exc}", file=sys.stderr)
            return 2
    else:
        folded_terms = args.terms if args.case_sensitive else [term.casefold() for term in args.terms]

    shown = 0
    files_searched = 0
    for key, path in selected_files(args.reference):
        if shown >= args.max_results:
            break
        if not path.is_file():
            print(f"Missing reference: {path}", file=sys.stderr)
            continue

        files_searched += 1
        lines = path.read_text(encoding="utf-8").splitlines()
        for index, line in enumerate(lines):
            if pattern is not None:
                matched = pattern.search(line) is not None
            else:
                candidate = line if args.case_sensitive else line.casefold()
                matched = all(term in candidate for term in folded_terms)
            if not matched:
                continue

            shown += 1
            print(f"\n### {key}: references/{path.name}:{index + 1}")
            start = max(0, index - args.context)
            stop = min(len(lines), index + args.context + 1)
            for context_index in range(start, stop):
                marker = ">" if context_index == index else " "
                content = clipped(lines[context_index], args.line_width)
                print(f"{marker} {context_index + 1:>8} | {content}")
            if shown >= args.max_results:
                break

    if shown == 0:
        print("No matches found. Try a synonym, another reference, or a broader term.")
    else:
        suffix = " (result cap reached)" if shown >= args.max_results else ""
        print(f"\nShowing {shown} match(es) across {files_searched} searched file(s){suffix}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
