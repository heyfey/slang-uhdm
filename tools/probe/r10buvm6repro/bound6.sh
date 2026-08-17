#!/usr/bin/env bash
# r10buvm6 BOUNDARY CHECK — the standing rules protect the arms of the
# neighbouring passes ("buvm3/4/5 arms, sd8-12 grids, uvm77-81 arms — only cells
# your law names may move").  Many of those arm files DO contain `[$]`, so
# "my law touches nothing there" cannot be asserted; it has to be measured.
#
#   usage: bound6.sh <patched-binary> <pristine-binary> <outdir> <armfile> [...]
#
# For each arm file it runs BOTH binaries (Surelog is never run — the question is
# ours-vs-ours, not ours-vs-golden) and reports TWO numbers:
#
#   DIFFLINES  the raw `-`/`+` line count between the two dumps.
#   RESIDUE    the same count AFTER `stripdollar.py` has removed every `$`
#              CONSTANT BLOCK from both sides.  RESIDUE > 0 is a change this
#              pass's law does not account for, and it is printed in full.
#
# The first version of this script classified each differing LINE against a
# regex.  Its own positive control (this pass's three arms) flagged the dump's
# CARRIER lines — the `\_bit_select:` header the dump prints inside the child
# constant's `|vpiParent:` field — as "out of law", because the regex covered the
# label and not the value.  On the 63 protected arms nothing moved at all, so the
# defect was INVISIBLE exactly where the script was being trusted.  Block
# stripping has no classifier to get wrong; a positive control that must print
# DIFFLINES>0 and RESIDUE=0 is kept and is the reason the fix is provable.
#
# GUARDS:
#   * uhdm-dump's FIRST LINE IS THE DATABASE PATH and always differs -> `sed 1d`.
#   * a binary that produces NO database is reported NO_DB and COUNTED; a driver
#     that reaches nothing must never read as "no movers".
#   * each arm runs in its OWN scratch dir, because builtin.sv synthesis and
#     relative includes both key off the cwd.
set -u
P=${1:?patched binary}
R=${2:?pristine binary}
OUT=${3:?outdir}
shift 3
for b in "$P" "$R"; do [ -x "$b" ] || { echo "FATAL: no binary $b"; exit 3; }; done
HERE=$(cd "$(dirname "$0")" && pwd)
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
STRIP=$HERE/stripdollar.py
[ -f "$STRIP" ] || { echo "FATAL: no $STRIP"; exit 3; }
mkdir -p "$OUT" || exit 9
tot=0; nodb=0; moved=0; resid=0
printf "%-46s %10s %8s %s\n" ARM DIFFLINES RESIDUE NOTE
for f in "$@"; do
  b=$(basename "$f"); b=${b%.*}
  d=$OUT/$b; rm -rf "$d"; mkdir -p "$d" || exit 9
  cp "$f" "$d/" || exit 9
  leaf=$(basename "$f")
  ( cd "$d" && "$P" "$leaf" -o pat.uhdm >pat.log 2>&1; \
               "$R" "$leaf" -o pris.uhdm >pris.log 2>&1 )
  tot=$((tot+1))
  if [ ! -f "$d/pat.uhdm" ] || [ ! -f "$d/pris.uhdm" ]; then
    printf "%-46s %10s %8s %s\n" "$b" - - \
      "NO_DB(pat=$( [ -f "$d/pat.uhdm" ] && echo y || echo n) pris=$( [ -f "$d/pris.uhdm" ] && echo y || echo n))"
    nodb=$((nodb+1)); continue
  fi
  "$DUMP" "$d/pat.uhdm"  2>/dev/null | sed 1d > "$d/pat.dump"
  "$DUMP" "$d/pris.uhdm" 2>/dev/null | sed 1d > "$d/pris.dump"
  diff -u "$d/pris.dump" "$d/pat.dump" > "$d/d.diff" || true
  n=$(grep -E '^[-+]' "$d/d.diff" | grep -vcE '^(---|\+\+\+) ' || true)
  python3 "$STRIP" "$d/pris.dump" > "$d/pris.strip"
  python3 "$STRIP" "$d/pat.dump"  > "$d/pat.strip"
  diff -u "$d/pris.strip" "$d/pat.strip" > "$d/s.diff" || true
  r=$(grep -E '^[-+]' "$d/s.diff" | grep -vcE '^(---|\+\+\+) ' || true)
  note=OK
  [ "$n" -gt 0 ] && { moved=$((moved+1)); note=MOVED; }
  if [ "$r" -gt 0 ]; then note=RESIDUE; resid=$((resid+1)); fi
  printf "%-46s %10s %8s %s\n" "$b" "$n" "$r" "$note"
  if [ "$r" -gt 0 ]; then
    echo "     ---- RESIDUE lines (- = pristine, + = patched):"
    grep -E '^[-+]' "$d/s.diff" | grep -vE '^(---|\+\+\+) ' | head -20 | sed 's/^/     /'
  fi
done
echo "-- arms=$tot MOVED=$moved RESIDUE-ARMS=$resid NO_DB=$nodb"
[ "$resid" -eq 0 ] && echo "PASS: outside the \$ constants the two dumps are IDENTICAL" \
                   || { echo "FAIL: a change outside the \$ constants"; exit 1; }
