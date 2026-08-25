#!/bin/bash
# r10uvm149 — GRID DRIVER.  MEASUREMENT ONLY: the official
# ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole judge; this script builds the
# three databases per arm (Surelog golden, pristine ours, patched ours) and
# reports the typespec_member census through ct149cen.
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# GUARDS (each an ops trap this campaign has paid for):
#   * SUBDIRECTORY arms are compiled — the file list is produced by `find` and
#     read on FD 3, and every child gets </dev/null so no child can swallow it;
#   * PROCESSED is asserted against LISTED — a driver that ran nothing must
#     never print green;
#   * scratch is keyed on the arm's RELATIVE path (every arm here is named
#     dut.sv, in five different subdirectories, on purpose);
#   * every invocation's rc is RECORDED (verify_golden records rc=139 segfaults
#     as SLANG_REJECT wearing the last stderr warning);
#   * the binaries come from the environment and are PRINTED, so a run can be
#     audited by binary PATH (SLANG_UHDM silently defaults to the main tree);
#   * `grep -c` with zero matches is followed by `; true` (it kills set -e).
set -u
SRCDIR=${SRCDIR:?set SRCDIR to the arm directory}
WD=${WD:?set WD to this pass own scratch}
PRIS=${PRIS:?set PRIS to the frozen pristine binary}
PAT=${PAT:-$PRIS}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
CEN=${CT149CEN:?set CT149CEN to the built ct149cen}
echo "BINARIES pris=$PRIS pat=$PAT surelog=$SURELOG cmp=$CMP cen=$CEN"
mkdir -p "$WD" || exit 1
listed=0; processed=0
: > "$WD/ARMS.txt"
while read -r -u 3 f; do
  listed=$((listed+1))
  rel=${f#"$SRCDIR"/}
  key=$(echo "$rel" | tr '/' '_'); key=${key%.sv}
  o="$WD/$key"; mkdir -p "$o"
  ( cd "$SRCDIR" && "$SURELOG" -parse -sv "$rel" -mt 0 -mp 0 -o "$o/sl" ) </dev/null >"$o/sl.log" 2>&1
  grc=$?
  ( cd "$SRCDIR" && "$PRIS" "$rel" --single-unit -o "$o/pris.uhdm" ) </dev/null >"$o/pris.log" 2>&1
  prc=$?
  ( cd "$SRCDIR" && "$PAT" "$rel" --single-unit -o "$o/pat.uhdm" ) </dev/null >"$o/pat.log" 2>&1
  qrc=$?
  G="$o/sl/slpp_all/surelog.uhdm"
  [ -f "$G" ] || G="$o/sl/surelog.uhdm"
  pl="-"; ql="-"; ph="-"; qh="-"
  if [ -f "$G" ] && [ -f "$o/pris.uhdm" ]; then
    "$CMP" "$G" "$o/pris.uhdm" > "$o/pris.cmp" 2>&1
    pl=$(wc -l < "$o/pris.cmp"); ph=$(grep -c '^LHS:' "$o/pris.cmp"; true)
  fi
  if [ -f "$G" ] && [ -f "$o/pat.uhdm" ]; then
    "$CMP" "$G" "$o/pat.uhdm" > "$o/pat.cmp" 2>&1
    ql=$(wc -l < "$o/pat.cmp"); qh=$(grep -c '^LHS:' "$o/pat.cmp"; true)
  fi
  for tag in sl:$G pris:$o/pris.uhdm pat:$o/pat.uhdm; do
    n=${tag%%:*}; db=${tag#*:}
    if [ -f "$db" ]; then "$CEN" "$db" "$n.$key" > "$o/cen.$n.txt" 2>&1; else : > "$o/cen.$n.txt"; fi
  done
  gm=$(grep -c '^M	' "$o/cen.sl.txt"; true)
  pm=$(grep -c '^M	' "$o/cen.pris.txt"; true)
  qm=$(grep -c '^M	' "$o/cen.pat.txt"; true)
  ga=$(grep -c 'array_typespec' "$o/cen.sl.txt"; true)
  pa=$(grep -c 'array_typespec' "$o/cen.pris.txt"; true)
  qa=$(grep -c 'array_typespec' "$o/cen.pat.txt"; true)
  bid="differ"
  if [ -f "$o/pris.uhdm" ] && [ -f "$o/pat.uhdm" ]; then
    cmp -s "$o/pris.uhdm" "$o/pat.uhdm" && bid="BYTE-IDENTICAL"
  fi
  printf "%-22s slrc=%s prisrc=%s patrc=%s | members g=%s p=%s q=%s | ats g=%s p=%s q=%s | cmp pris=%s(%s) pat=%s(%s) | ours %s\n" \
     "$rel" "$grc" "$prc" "$qrc" "$gm" "$pm" "$qm" "$ga" "$pa" "$qa" "$pl" "$ph" "$ql" "$qh" "$bid" | tee -a "$WD/ARMS.txt"
  processed=$((processed+1))
done 3< <(find "$SRCDIR" -name '*.sv' | sort)
echo "LISTED=$listed PROCESSED=$processed"
[ "$listed" -eq "$processed" ] && [ "$listed" -gt 0 ] && echo "ARM-DRIVER OK" || echo "ARM-DRIVER FAIL"
