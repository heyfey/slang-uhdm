#!/usr/bin/env bash
# v82 verifier — build one arm with Surelog (golden) and both frozen binaries,
# score against GOLDEN with the OFFICIAL uhdm-cmp in the DEF view, and diff the
# two binaries' ELAB dumps (path-normalised, order-blind) for movement the judge
# cannot see.  MEASUREMENT ONLY.
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
PRIS=${PRIS:?}; PAT=${PAT:?}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -sv "$B" >sl.log 2>&1 </dev/null ); slrc=$?
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
( cd "$D" && "$PRIS" "$B"            -o o.uhdm  >o.log  2>&1 </dev/null ); orc=$?
( cd "$D" && "$PAT"  "$B"            -o q.uhdm  >q.log  2>&1 </dev/null ); qrc=$?
( cd "$D" && R10E82_OFF=1 "$PAT" "$B" -o n.uhdm >n.log  2>&1 </dev/null ); nrc=$?
( cd "$D" && "$PRIS" "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); oerc=$?
( cd "$D" && "$PAT"  "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); qerc=$?
( cd "$D" && R10E82_OFF=1 "$PAT" "$B" --elabuhdm -o ne.uhdm >ne.log 2>&1 </dev/null ); nerc=$?
pl=NA; ql=NA; ph=NA; qh=NA; v=NO-GOLDEN
if [ -f "$D/g.uhdm" ] && [ -f "$D/o.uhdm" ] && [ -f "$D/q.uhdm" ]; then
  "$CMP" "$D/g.uhdm" "$D/o.uhdm" > "$D/o.cmp" 2>&1
  "$CMP" "$D/g.uhdm" "$D/q.uhdm" > "$D/q.cmp" 2>&1
  pl=$(wc -l < "$D/o.cmp"); ql=$(wc -l < "$D/q.cmp")
  ph=$(grep -c '^LHS:' "$D/o.cmp" || true); qh=$(grep -c '^LHS:' "$D/q.cmp" || true)
  v=SAME; [ "$ql" -lt "$pl" ] && v=CLOSER; [ "$ql" -gt "$pl" ] && v=FURTHER
  [ "$ql" = "$pl" ] && ! cmp -s "$D/o.cmp" "$D/q.cmp" && v=SAME-COUNT-DIFF-LOG
fi
# byte movement, both views, and the KILL-SWITCH neutrality check
bd=SAME; cmp -s "$D/o.uhdm" "$D/q.uhdm" || bd=MOVED
be=SAME; cmp -s "$D/oe.uhdm" "$D/qe.uhdm" || be=MOVED
nz=NEUTRAL-OK; cmp -s "$D/o.uhdm" "$D/n.uhdm" || nz=NEUTRAL-DIFFERS
nze=NEUTRAL-OK; cmp -s "$D/oe.uhdm" "$D/ne.uhdm" || nze=NEUTRAL-DIFFERS
printf "%-22s slrc=%s rc(o/q/n/oe/qe/ne)=%s/%s/%s/%s/%s/%s  GOLDEN pris=%s/%sh patc=%s/%sh %-18s def=%s elab=%s %s %s\n" \
  "$B" "$slrc" "$orc" "$qrc" "$nrc" "$oerc" "$qerc" "$nerc" "$pl" "$ph" "$ql" "$qh" "$v" "$bd" "$be" "$nz" "$nze"
