#!/usr/bin/env bash
# vrgg15 adversarial cell driver. usage: cell.sh <celldir> <binary> <suffix> [--elabuhdm]
set -u
D=${1:?celldir}; BIN=${2:?bin}; SFX=${3:?sfx}; EL=${4:-}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
cd "$D" || exit 3
GB=golden${EL:+_elab}.uhdm
rm -rf slpp_all
if [ ! -f "$GB" ]; then
  $SL -parse -mt 0 -mp 0 $EL *.sv > sl${EL:+_elab}.log 2>&1
  [ -f slpp_all/surelog.uhdm ] && cp slpp_all/surelog.uhdm "$GB"
fi
rm -rf slpp_all
OB=ours${EL:+_elab}$SFX.uhdm
"$BIN" *.sv --single-unit ${EL:+--elabuhdm} -o "$OB" > slang${EL:+_elab}$SFX.log 2>&1
rc=$?
if [ -f "$GB" ] && [ -f "$OB" ]; then
  $CMP "$GB" "$OB" > cmp${EL:+_elab}$SFX.txt 2>&1
  echo "$(basename $D)${EL:+/elab}$SFX rc=$rc cmplines=$(wc -l < cmp${EL:+_elab}$SFX.txt) heads=$(grep -c '^LHS:' cmp${EL:+_elab}$SFX.txt; true)"
else
  echo "$(basename $D)${EL:+/elab}$SFX MISSING golden=$([ -f $GB ] && echo y || echo n) ours=$([ -f $OB ] && echo y || echo n) rc=$rc"
fi
