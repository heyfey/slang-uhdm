#!/usr/bin/env bash
# r10v61 VERIFIER 3-way arm driver: golden / pristine / patched, one view.
#   usage: PAT=... PRIS=... v61arm.sh <arm.sv> <wd> [--elab]
set -u
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
SRC=${1:?arm}; D=${2:?wd}; ELAB=${3:-}
: "${PAT:?}"; : "${PRIS:?}"
SLE=""; SUE=""
[ "$ELAB" = "--elab" ] && { SLE="--elabuhdm"; SUE="-elabuhdm"; }
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
B=$(basename "$SRC")
cd "$D" || exit 9
"$SURELOG" -parse $SUE -nocache -mt 0 -mp 0 "$B" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo "SURELOG_FAIL"; tail -12 surelog.log; exit 5; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' > g.dump
for side in pris pat; do
  case $side in pris) BIN=$PRIS;; pat) BIN=$PAT;; esac
  "$BIN" $SLE --single-unit "$B" -o $side.uhdm >$side.log 2>&1; rc=$?
  if [ ! -f $side.uhdm ]; then echo "$side NO_OUTPUT rc=$rc"; tail -5 $side.log; continue; fi
  "$DUMP" $side.uhdm 2>/dev/null | sed '1d' > $side.dump
  if "$CMP" slpp_all/surelog.uhdm $side.uhdm >$side.cmp 2>&1; then v=PASS_CMP; else v=CMP_FAIL; fi
  echo "$side: $v heads=$(grep -c '^LHS:' $side.cmp; true) cmplines=$(wc -l < $side.cmp) rc=$rc"
done
if [ -s pris.dump ] && [ -s pat.dump ]; then
  if cmp -s pris.dump pat.dump; then echo "PRIS_VS_PAT: IDENTICAL"; else
    echo "PRIS_VS_PAT: DIFFERS ($(diff pris.dump pat.dump | grep -cE '^[<>]') lines)"; fi
fi
echo "WD=$D"
