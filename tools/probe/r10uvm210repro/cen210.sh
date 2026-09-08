#!/usr/bin/env bash
# r10uvm210 — THE CORPUS CENSUS of package/module `param_assign` Rhs FORMS.
# MEASUREMENT ONLY; `uhdm-cmp` is the judge.  LHS is ALWAYS golden.
#
# For every row of a verify_golden workdir that has BOTH databases, emit the
# multiset of keys
#     <owner-kind> | <view> | <Lhs name> | <Lhs line:col> | <Rhs FORM> | <ref ACTUAL kind>
# on each side and report the two ONE-SIDED sets.  Rhs FORM is REF / CONST / OP /
# OTHER — the DEFAULT FORM the brief asks the split to be keyed on — and the
# ACTUAL column is the `ref_obj::Actual_group` kind, which `ref_obj::Compare`
# reads (generated ref_obj.cpp) and which is therefore part of the cell, not
# decoration.
#
# The DEF/ELAB view IS in the key here on purpose: this family's whole question
# is which VIEW keeps the reference, and both producers label the two package
# listings the same way (AllPackages vs TopPackages), so the usual "keep the
# view out of the key" caution (RESUME §8) does not apply.
#
# usage: OWN=<ct210own> ./cen210.sh <sweep-workdir> <out> [name-filter-regex]
#
# GUARDS: a row missing EITHER database is printed as SKIP-NOFILE and counted —
# a census that reaches nothing must never read as perfection; the golden is read
# out of the row's OWN cmds.txt so the wrong golden cannot be scored; `grep -c`
# never sits in a `set -e` position.
set -u
OWN=${OWN:?path to ct210own}
WD=${1:?sweep workdir}
OUT=${2:?out}
FILT=${3:-.}
[ -x "$OWN" ] || { echo "FATAL: no $OWN"; exit 3; }
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
T=$(mktemp -d "${TMPDIR:-/tmp}/r10uvm210_cen.XXXXXX") || exit 1
trap 'rm -rf "$T"' EXIT
: > "$OUT"
rows=0; skip=0; bad=0
for mode in default testflags; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    b=$(basename "$d")
    n=${b%-*}
    case "$n" in $FILT) ;; *) [ "$FILT" = "." ] || continue;; esac
    O=$d/slang.uhdm
    C=$d/cmds.txt
    G=""
    [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
      echo "SKIP-NOFILE $n $mode"; skip=$((skip+1)); continue
    fi
    "$OWN" --key "$G" G 2>/dev/null | grep '^K ' | sort > "$T/g"; true
    "$OWN" --key "$O" O 2>/dev/null | grep '^K ' | sort > "$T/o"; true
    ag=$(comm -12 "$T/g" "$T/o" | wc -l)
    og=$(comm -23 "$T/g" "$T/o" | wc -l)
    oo=$(comm -13 "$T/g" "$T/o" | wc -l)
    echo "ROW $n $mode AGREE=$ag ONLY-GOLDEN=$og ONLY-OURS=$oo" >> "$OUT"
    if [ "$og" -ne 0 ] || [ "$oo" -ne 0 ]; then
      bad=$((bad+1))
      comm -23 "$T/g" "$T/o" | sed "s/^/  G-ONLY $n.$mode /" >> "$OUT"
      comm -13 "$T/g" "$T/o" | sed "s/^/  O-ONLY $n.$mode /" >> "$OUT"
    fi
    rows=$((rows+1))
  done
done
{
  echo "-- ROWS SCORED: $rows   SKIP-NOFILE: $skip   ROWS WITH ANY ONE-SIDED CELL: $bad"
  echo "-- TOTAL ONLY-GOLDEN: $(awk -F'ONLY-GOLDEN=' '/^ROW /{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")"
  echo "-- TOTAL ONLY-OURS  : $(awk -F'ONLY-OURS=' '/^ROW /{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")"
  echo "-- TOTAL AGREE      : $(awk -F'AGREE=' '/^ROW /{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")"
} >> "$OUT"
tail -4 "$OUT"
