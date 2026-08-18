#!/usr/bin/env bash
# r10vrgg16 adversarial cell driver.  usage: vcell16.sh <celldir> <bin> <sfx> [--elabuhdm]
# Mirrors verify_golden.py's `default` mode: surelog `-parse <srcs>`, slang
# `<srcs> --single-unit`.  The golden is cached per (cell, view).
set -u
D=${1:?celldir}; BIN=${2:?bin}; SFX=${3:?sfx}; EL=${4:-}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/.local/bin/uhdm-cmp
cd "$D" || exit 3
TAG=${EL:+_elab}
GB=golden$TAG.uhdm
rm -rf slpp_all
if [ ! -f "$GB" ]; then
  $SL -parse -mt 0 -mp 0 $EL *.sv > sl$TAG.log 2>&1
  [ -f slpp_all/surelog.uhdm ] && cp slpp_all/surelog.uhdm "$GB"
fi
rm -rf slpp_all
OB=ours$TAG$SFX.uhdm
"$BIN" *.sv --single-unit ${EL:+--elabuhdm} -o "$OB" > slang$TAG$SFX.log 2>&1
rc=$?
if [ -f "$GB" ] && [ -f "$OB" ]; then
  $CMP "$GB" "$OB" > cmp$TAG$SFX.txt 2>&1
  echo "$(basename $D)$TAG$SFX rc=$rc cmplines=$(wc -l < cmp$TAG$SFX.txt) heads=$(grep -c '^LHS:' cmp$TAG$SFX.txt; true)"
else
  echo "$(basename $D)$TAG$SFX MISSING golden=$([ -f $GB ] && echo y || echo n) ours=$([ -f $OB ] && echo y || echo n) rc=$rc"
fi
