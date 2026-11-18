#!/bin/bash
# Convert .skill files (which are zip archives) into .zip files that some agents
# require for skill import. Each output .zip contains the skill's top-level
# folder (e.g. oceanbase-config-items/SKILL.md + references/...).
#
# Usage:
#   cd scripts/skills/oceanbase-sql-compat
#   bash make-zip-imports.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="$SCRIPT_DIR/zip"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$OUT_DIR"

# Self-contained Perl helper for creating a zip from a directory.
# Used when the system 'zip' command is not available.
ZIP_HELPER="$TMP_DIR/zip_dir.pl"
cat > "$ZIP_HELPER" <<'PERL'
#!/usr/bin/perl
use strict;
use warnings;
use IO::Compress::Zip qw(zip $ZipError);
use File::Find;
use Cwd;

my ($src_dir, $out_zip) = @ARGV;
die "Usage: zip_dir.pl <source_dir> <output.zip>\n" unless defined $src_dir && defined $out_zip;
die "Source directory does not exist: $src_dir\n" unless -d $src_dir;

$src_dir =~ s#\\#/#g;
$src_dir =~ s#/$##;
$out_zip =~ s#\\#/#g;

my $parent = ".";
my $base = $src_dir;
if ($src_dir =~ m#^(.+)/([^/]+)$#) {
    $parent = $1;
    $base = $2;
}

my @files;
find(sub {
    return if -d $_;
    my $full = $File::Find::name;
    $full =~ s#\\#/#g;
    my $rel = $full;
    my $prefix = "$parent/";
    $rel =~ s/^\Q$prefix\E//;
    $rel =~ s/^\Q$parent\E\///;
    push @files, $rel;
}, $src_dir);

die "No files found in $src_dir\n" unless @files;

my $orig_dir = getcwd();
chdir $parent or die "Cannot chdir to $parent: $!\n";
zip \@files => $out_zip or die "zip failed: $ZipError\n";
chdir $orig_dir or die "Cannot chdir back to $orig_dir: $!\n";
print "Created $out_zip with " . scalar(@files) . " files\n";
PERL

# Detect zip tool: prefer system 'zip', else fall back to Perl.
if command -v zip >/dev/null 2>&1; then
    ZIP_TOOL="zip"
else
    ZIP_TOOL="perl"
    perl -MIO::Compress::Zip=zip -e 1 >/dev/null 2>&1 || {
        echo "ERROR: neither 'zip' nor Perl IO::Compress::Zip is available." >&2
        echo "Install 'zip' or Perl with IO::Compress::Zip and try again." >&2
        exit 1
    }
fi

for skill_file in "$SCRIPT_DIR"/*.skill; do
    [ -e "$skill_file" ] || continue
    skill_name="$(basename "$skill_file" .skill)"
    out_zip="$OUT_DIR/${skill_name}.zip"

    echo "Converting $skill_name ..."

    # Unzip the skill archive into a temp dir.
    unzip -q -o "$skill_file" -d "$TMP_DIR/$skill_name-extract"

    # The extracted content should be a single folder named after the skill.
    extracted_dir="$TMP_DIR/$skill_name-extract/$skill_name"
    if [ ! -d "$extracted_dir" ]; then
        echo "WARNING: expected folder $skill_name not found after extracting $skill_file, skipping." >&2
        continue
    fi

    rm -f "$out_zip"

    if [ "$ZIP_TOOL" = "zip" ]; then
        (cd "$TMP_DIR/$skill_name-extract" && zip -r "$out_zip" "$skill_name" >/dev/null)
    else
        perl "$ZIP_HELPER" "$extracted_dir" "$out_zip"
    fi

    echo "  -> $out_zip ($(stat -c%s "$out_zip") bytes)"
done

echo "Done. Output in $OUT_DIR"
