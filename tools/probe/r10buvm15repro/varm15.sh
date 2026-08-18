#!/usr/bin/env bash
# vbuvm15 verifier arm runner: golden(surelog) / pristine / patched, ONE cwd
# (absolute source paths are recorded in the database), FATAL on empty db,
# FATAL on zero golden ref_objs.
set -u
: "${PRISTINE:?}"; : "${PATCHED:?}"
SRC=${1:?file.sv}
VERB=${2:-}
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
B=$(basename "$SRC" .sv)
W=$(mktemp -d /tmp/vbuvm15_arm_XXXXXX)
cp "$SRC" "$W/$B.sv"
cd "$W" || exit 3
"$SL" -parse "$B.sv" -mt 0 -mp 0 -nocache -d coveruhdm > sl.log 2>&1
G=slpp_all/surelog.uhdm
[ -s "$G" ] || { echo "SURELOG_FAIL $B wd=$W"; grep -iE 'error|fatal' sl.log|head -5; exit 4; }
"$PRISTINE" "$B.sv" -o p.uhdm > p.log 2>&1; rcp=$?
"$PATCHED"  "$B.sv" -o q.uhdm > q.log 2>&1; rcq=$?
[ -s p.uhdm ] || { echo "SLANG_REJECT(pristine rc=$rcp) $B wd=$W"; tail -6 p.log; exit 5; }
[ -s q.uhdm ] || { echo "SLANG_REJECT(patched rc=$rcq) $B wd=$W"; tail -6 q.log; exit 5; }
"$DUMP" "$G" > g.dump 2>&1; "$DUMP" p.uhdm > p.dump 2>&1; "$DUMP" q.uhdm > q.dump 2>&1
ng=$(grep -c '\\_ref_obj:' g.dump; true)
echo "== arm $B wd=$W  rc(p)=$rcp rc(q)=$rcq  golden_ref_objs=$ng"
[ "$ng" -gt 0 ] || { echo "FATAL arm $B has ZERO golden ref_obj -- tests nothing"; exit 7; }
python3 "$(dirname "$0")"/vrefgrid15.py g.dump p.dump q.dump $VERB
echo "-- cmp heads: pristine=$($HOME/git-repos/UHDM/build/bin/uhdm-cmp "$G" p.uhdm 2>&1 | grep -c '^LHS:'; true) patched=$($HOME/git-repos/UHDM/build/bin/uhdm-cmp "$G" q.uhdm 2>&1 | grep -c '^LHS:'; true)"
echo "-- cmp lines: pristine=$($HOME/git-repos/UHDM/build/bin/uhdm-cmp "$G" p.uhdm 2>&1 | wc -l) patched=$($HOME/git-repos/UHDM/build/bin/uhdm-cmp "$G" q.uhdm 2>&1 | wc -l)"
