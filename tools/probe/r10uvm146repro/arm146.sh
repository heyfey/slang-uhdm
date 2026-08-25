#!/bin/bash
# r10uvm146 — GRID DRIVER.  MEASUREMENT ONLY: the official
# ~/git-repos/UHDM/build/bin/uhdm-cmp is the judge; this script only builds the
# three databases per arm (Surelog golden, pristine ours, patched ours) and
# reports the design-level imported-parameter listing plus the reference
# bindings through ct146cen.
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# GUARDS (each an ops trap this campaign has paid for):
#   * the file list is read on FD 3 and every child gets </dev/null, so no child
#     can swallow the list;
#   * PROCESSED is asserted against LISTED — a driver that ran nothing must
#     never print green;
#   * scratch is keyed on the arm's RELATIVE path, so two arms with the same
#     basename in different subdirectories cannot collide;
#   * every invocation's rc is RECORDED (verify_golden records rc=139 segfaults
#     as SLANG_REJECT wearing the last stderr warning);
#   * the binaries are taken from the environment and PRINTED, so a run can be
#     audited by binary path (SLANG_UHDM silently defaults to the main tree).
set -u
SRCDIR=${SRCDIR:?set SRCDIR to the arm directory}
WD=${WD:?set WD to this pass own scratch}
PRIS=${PRIS:?set PRIS to the frozen pristine binary}
PAT=${PAT:?set PAT to the frozen patched binary}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
CEN=${CT146CEN:?set CT146CEN to the built ct146cen}
echo "BINARIES pris=$PRIS pat=$PAT surelog=$SURELOG cmp=$CMP"
mkdir -p "$WD" || exit 1
listed=0; processed=0
: > "$WD/ARMS.txt"
while read -r -u 3 f; do
  listed=$((listed+1))
  rel=${f#"$SRCDIR"/}
  key=$(echo "$rel" | tr '/' '_')
  key=${key%.sv}
  o="$WD/$key"; mkdir -p "$o"
  ( cd "$SRCDIR" && "$SURELOG" -parse -sv "$rel" -mt 0 -mp 0 -o "$o/sl" ) </dev/null >"$o/sl.log" 2>&1
  grc=$?
  ( cd "$SRCDIR" && "$PRIS" "$rel" --single-unit -o "$o/pris.uhdm" ) </dev/null >"$o/pris.log" 2>&1
  prc=$?
  ( cd "$SRCDIR" && "$PAT" "$rel" --single-unit -o "$o/pat.uhdm" ) </dev/null >"$o/pat.log" 2>&1
  qrc=$?
  G="$o/sl/slpp_all/surelog.uhdm"
  [ -f "$G" ] || G="$o/sl/surelog.uhdm"
  gl="-"; pl="-"; ql="-"; gh="-"; ph="-"; qh="-"
  if [ -f "$G" ] && [ -f "$o/pris.uhdm" ]; then
    "$CMP" "$G" "$o/pris.uhdm" > "$o/pris.cmp" 2>&1; pl=$(wc -l < "$o/pris.cmp"); ph=$(grep -c '^LHS:' "$o/pris.cmp"; true)
  fi
  if [ -f "$G" ] && [ -f "$o/pat.uhdm" ]; then
    "$CMP" "$G" "$o/pat.uhdm" > "$o/pat.cmp" 2>&1; ql=$(wc -l < "$o/pat.cmp"); qh=$(grep -c '^LHS:' "$o/pat.cmp"; true)
  fi
  for tag in sl:$G pris:$o/pris.uhdm pat:$o/pat.uhdm; do
    n=${tag%%:*}; db=${tag#*:}
    [ -f "$db" ] && "$CEN" "$db" > "$o/cen.$n.txt" 2>&1 || : > "$o/cen.$n.txt"
  done
  gp=$(grep -c '^LIST|PARAM' "$o/cen.sl.txt"; true)
  pp=$(grep -c '^LIST|PARAM' "$o/cen.pris.txt"; true)
  qp=$(grep -c '^LIST|PARAM' "$o/cen.pat.txt"; true)
  ga=$(grep -c '^LIST|PASSIGN' "$o/cen.sl.txt"; true)
  qa=$(grep -c '^LIST|PASSIGN' "$o/cen.pat.txt"; true)
  printf "%-24s slrc=%s prisrc=%s patrc=%s | GOLDlist=%s/%s PRISlist=%s PATlist=%s/%s | cmp pris=%s(%s) pat=%s(%s)\n" \
     "$rel" "$grc" "$prc" "$qrc" "$gp" "$ga" "$pp" "$qp" "$qa" "$pl" "$ph" "$ql" "$qh" | tee -a "$WD/ARMS.txt"
  processed=$((processed+1))
done 3< <(find "$SRCDIR" -name '*.sv' | sort)
echo "LISTED=$listed PROCESSED=$processed"
[ "$listed" -eq "$processed" ] && [ "$listed" -gt 0 ] && echo "ARM-DRIVER OK" || echo "ARM-DRIVER FAIL"
