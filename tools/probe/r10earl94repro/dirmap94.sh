#!/usr/bin/env bash
# r10earl93 — REGENERATE THE DIRMAP `predict93.sh` needs.  MEASUREMENT ONLY;
# it walks directories and DISPATCHES NOTHING.
#
# `verify_golden.py` names each workdir `<test>-<sha1(dirpath)[:8]>`
# (scripts/verify_golden.py, `compare()`), so this table inverts that suffix
# back to the directory the harness ran slang in.
#
# THE FENCE.  The five directory hashes in FENCED below are the SLANG-FENCED
# TESTS' source directories.  They are listed as OPAQUE HASHES — this file, and
# every other file in this directory, is free of their names — and they are
# OMITTED from the map, so `predict93.sh` finds no source for them, prints
# FENCED-SKIP and runs nothing.  Do not "fix" this by adding them back.
#
#   usage: dirmap93.sh > DIRMAP.txt
set -u
FENCED="499af5fe 4dd24c06 67e3eef8 b8ba49d5 e420460c"
ROOTS="$HOME/git-repos/uhdm2rtlil/test
$HOME/git-repos/Surelog/tests
$HOME/git-repos/Surelog/third_party/tests
$HOME/git-repos/sv-tests/third_party/tools/Surelog/third_party/UVM"
echo "$ROOTS" | while read -r r; do
  [ -d "$r" ] || continue
  find "$r" -type d -print
done | sort -u | while read -r d; do
  h=$(printf '%s' "$d" | sha1sum | cut -c1-8)
  case " $FENCED " in *" $h "*) continue;; esac
  printf '%s %s\n' "$h" "$d"
done
