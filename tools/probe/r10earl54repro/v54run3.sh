#!/usr/bin/env bash
# v54 verifier 3-way arm driver: GOLDEN (surelog) + pristine + patched, one VIEW.
#   usage: run3.sh <abs.sv> <view: plain|elab> <outroot>
set -u
SRC=${1:?src}; VIEW=${2:?view}; ROOT=${3:?outroot}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
PAT=${PAT:?set PAT to the patched binary}
PRIS=${PRIS:?set PRIS to the pristine binary}
B=$(basename "$SRC" .sv)
case $VIEW in plain) SLF="";  SUF="-parse";;
              elab)  SLF="--elabuhdm"; SUF="-parse -elabuhdm";; esac
D="$ROOT/${B}_$VIEW"; rm -rf "$D"; mkdir -p "$D/g" "$D/pris" "$D/pat"
for s in g pris pat; do cp "$SRC" "$D/$s/"; done
( cd "$D/g" && $SURELOG $SUF -nocache -mt 0 -mp 0 "$B.sv" >surelog.log 2>&1 )
[ -f "$D/g/slpp_all/surelog.uhdm" ] || { echo "$B/$VIEW SURELOG_FAIL"; tail -5 "$D/g/surelog.log"; exit 5; }
$DUMP "$D/g/slpp_all/surelog.uhdm" 2>/dev/null | sed '1d' | sed "s#$D/g#WD#g" > "$D/g.dump"
for s in pris pat; do
  case $s in pris) BIN=$PRIS;; pat) BIN=$PAT;; esac
  ( cd "$D/$s" && $BIN $SLF "$B.sv" -o slang.uhdm >slang.log 2>&1 )
  [ -f "$D/$s/slang.uhdm" ] || { echo "$B/$VIEW NO_OUTPUT($s)"; tail -5 "$D/$s/slang.log"; exit 6; }
  $DUMP "$D/$s/slang.uhdm" 2>/dev/null | sed '1d' | sed "s#$D/$s#WD#g" > "$D/$s.dump"
  $CMP "$D/g/slpp_all/surelog.uhdm" "$D/$s/slang.uhdm" > "$D/cmp_$s.log" 2>&1
done
hp=$(grep -c '^LHS:' "$D/cmp_pris.log"; true); ha=$(grep -c '^LHS:' "$D/cmp_pat.log"; true)
lp=$(wc -l < "$D/cmp_pris.log"); la=$(wc -l < "$D/cmp_pat.log")
dp=$(diff "$D/g.dump" "$D/pris.dump" | grep -cE '^[<>]'; true)
da=$(diff "$D/g.dump" "$D/pat.dump" | grep -cE '^[<>]'; true)
op=$(cmp -s "$D/pris.dump" "$D/pat.dump" && echo SAME || echo DIFF)
printf '%-10s %-5s cmpheads pris=%s pat=%s | cmplines pris=%s pat=%s | g-vs-ours sides pris=%s pat=%s | pris-vs-pat=%s\n' \
  "$B" "$VIEW" "$hp" "$ha" "$lp" "$la" "$dp" "$da" "$op"
