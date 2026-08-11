#!/usr/bin/env bash
# r10oth9 — ATTRIBUTE a byte mover by DIFFING THE DUMPS and classifying the
# changed lines.  A mover is not a regression until it has been READ.
#
#   usage: ct9movers.sh <patched_wd_root> <pristine_wd_root> <relpath...>
#          (relpath as byteverify.sh prints it, e.g. ./default/SVSwitch-xx/slang.uhdm)
#
# WHY THIS EXISTS: r10oth8 §0.1 proved the UVM `vpiTypedefAlias` /
# `class_typespec` population is BUILD-DEPENDENT — a semantically-null edit moved
# BuildUVMPkg aliases 239->337 with the `vpiSigned` changed-line sets
# byte-identical.  So a UVM mover must be SPLIT into (a) lines carrying THIS
# pass's law and (b) that known instability, by content, not by test name.
#
# TRAPS ENCODED:
#   * uhdm-dump's FIRST LINE IS THE DATABASE PATH and always differs -> `sed 1d`.
#   * DUMP CONTENT = the `-`/`+` lines of `diff -u` MINUS diff's own `---`/`+++`
#     header (2 lines), so a naive count over-reports by exactly 2.
#   * indentation is STRIPPED before classifying, because the same object prints
#     at several depths and an indented duplicate is not a second object.
set -u
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
A=${1:?patched root}; B=${2:?pristine root}; shift 2
for p in "$@"; do
  echo "================ $p"
  "$DUMP" "$A/$p" 2>/dev/null | sed 1d > /tmp/r10oth9_mv_a.dump
  "$DUMP" "$B/$p" 2>/dev/null | sed 1d > /tmp/r10oth9_mv_b.dump
  # LHS is the PRISTINE dump, RHS the PATCHED one, so `+` reads as "what this
  # pass added".  (This script compares OUR two builds; it never touches golden,
  # so the LHS=golden convention does not apply and is not claimed.)
  diff -u /tmp/r10oth9_mv_b.dump /tmp/r10oth9_mv_a.dump > /tmp/r10oth9_mv.diff
  tot=$(grep -E '^[-+]' /tmp/r10oth9_mv.diff | grep -vcE '^(---|\+\+\+) ')
  echo "  content lines changed: $tot"
  ch=$(grep -E '^[-+]' /tmp/r10oth9_mv.diff | grep -vE '^(---|\+\+\+) ' | sed -E 's/^([-+])[[:space:]]*/\1/')
  echo "  --- BY CONTENT CLASS (indentation stripped) ---"
  printf '    %-34s %s\n' 'vpiSigned lines'        "$(echo "$ch" | grep -c 'vpiSigned')"
  printf '    %-34s %s\n' 'vpiParent edge lines'   "$(echo "$ch" | grep -c 'vpiParent')"
  printf '    %-34s %s\n' 'atom-typespec headers'  "$(echo "$ch" | grep -cE '(byte|int|integer|short_int|long_int|time)_typespec')"
  printf '    %-34s %s\n' 'atom-var headers'       "$(echo "$ch" | grep -cE '(byte|int|integer|short_int|long_int|time)_var')"
  printf '    %-34s %s\n' 'class_typespec lines'   "$(echo "$ch" | grep -c 'class_typespec')"
  printf '    %-34s %s\n' 'vpiTypedefAlias lines'  "$(echo "$ch" | grep -c 'vpiTypedefAlias')"
  printf '    %-34s %s\n' 'string_typespec lines'  "$(echo "$ch" | grep -c 'string_typespec')"
  echo "  --- the FIRST 12 changed lines, verbatim ---"
  echo "$ch" | head -12 | sed 's/^/    /'
  echo "  --- every DISTINCT changed line shape, with counts ---"
  echo "$ch" | sed -E 's/[0-9]+/N/g' | sort | uniq -c | sort -rn | head -14 | sed 's/^/    /'
done
