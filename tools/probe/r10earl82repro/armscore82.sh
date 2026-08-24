#!/usr/bin/env bash
# r10earl82 — SCORE A BOUNDARY MOVER AGAINST GOLDEN with the OFFICIAL judge.
# A patched-vs-pristine byte diff says a cell MOVED; only golden says WHICH WAY.
#
#   usage: PATCHED_BIN=.. PRISTINE_BIN=.. armscore82.sh <file.sv> <outdir>
#
# Builds Surelog's golden for the arm and runs the official `uhdm-cmp` against
# BOTH binaries.  Fewer cmp lines = closer to golden; the head logs are kept so
# the direction can be read, never inferred.  MEASUREMENT ONLY.
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
PAT=${PATCHED_BIN:?}; PRIS=${PRISTINE_BIN:?}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -sv "$B" >sl.log 2>&1 </dev/null )
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
[ -f "$D/g.uhdm" ] || { echo "$B  NO-GOLDEN"; exit 0; }
for side in pris patc; do
  case $side in pris) BIN=$PRIS;; patc) BIN=$PAT;; esac
  ( cd "$D" && "$BIN" "$B" -o $side.uhdm >$side.log 2>&1 </dev/null )
  "$CMP" "$D/g.uhdm" "$D/$side.uhdm" > "$D/$side.cmp" 2>&1
done
pl=$(wc -l < "$D/pris.cmp"); ql=$(wc -l < "$D/patc.cmp")
ph=$(grep -c '^LHS:' "$D/pris.cmp" || true); qh=$(grep -c '^LHS:' "$D/patc.cmp" || true)
v=SAME; [ "$ql" -lt "$pl" ] && v=CLOSER; [ "$ql" -gt "$pl" ] && v=FURTHER
if [ "$ql" = "$pl" ] && ! cmp -s "$D/pris.cmp" "$D/patc.cmp"; then v=SAME-COUNT-DIFFERENT-LOG; fi
printf "%-28s pristine=%s lines/%s heads   patched=%s lines/%s heads   %s\n" \
       "$B" "$pl" "$ph" "$ql" "$qh" "$v"
