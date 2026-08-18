#!/usr/bin/env bash
# r10uvm93 arm runner — MEASUREMENT-ONLY.  golden(Surelog) + BOTH binaries in
# ONE scratch dir keyed on the arm's RELATIVE path, so uhdm-dump's absolute
# paths are identical across the three reads.  LHS is ALWAYS golden.
#   PAT=<patched> PRI=<pristine> arm93.sh <arm.sv>
set -u
SRC=${1:?arm source}
PAT=${PAT:-}
PRI=${PRI:-}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
KEY=$(echo "$SRC" | sed 's#[^A-Za-z0-9._-]#_#g')
D=${ARMDIR:-/tmp/r10uvm93_arm}/$KEY
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
LEAF=$(basename "$SRC")
cd "$D" || exit 9
"$SURELOG" -parse -nocache "$LEAF" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo "SURELOG_FAIL $KEY"; tail -6 surelog.log; exit 5; }
echo "$KEY: surelog $(grep -cE '^\[(ERR|FAT)' surelog.log; true) ERR lines"
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed 1d > g.dump
for tag in pris pat; do
  bin=$PRI; [ $tag = pat ] && bin=$PAT
  [ -n "$bin" ] || continue
  "$bin" "$LEAF" -o $tag.uhdm > $tag.log 2>&1; rc=$?
  if [ ! -f $tag.uhdm ]; then echo "NO_OUTPUT $KEY/$tag rc=$rc"; tail -4 $tag.log; continue; fi
  "$DUMP" $tag.uhdm 2>/dev/null | sed 1d > $tag.dump
  res=$("$CMP" slpp_all/surelog.uhdm $tag.uhdm >$tag.cmp 2>&1 && echo PASS_CMP || echo CMP_FAIL)
  dd=$(diff g.dump $tag.dump | grep -cE '^[<>]'; true)
  echo "$KEY/$tag: rc=$rc $res cmpheads=$(grep -c '^LHS:' $tag.cmp; true) dumpdiff_lines=$dd"
done
if [ -f pris.dump ] && [ -f pat.dump ]; then
  cmp -s pris.dump pat.dump && echo "$KEY: pris/pat dumps BYTE-IDENTICAL" \
    || echo "$KEY: pris->pat moved $(diff pris.dump pat.dump | grep -cE '^[<>]'; true) dump lines"
fi
echo "WD=$D"
