#!/usr/bin/env bash
# r10uvm94 arm runner — MEASUREMENT ONLY.  golden(Surelog) LHS always.
#   PAT= PRI= MODE=def|elab run.sh <arm.sv>
set -u
SRC=${1:?arm}
PAT=${PAT:?}; PRI=${PRI:?}
MODE=${MODE:-def}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
KEY=$(basename "$SRC" .sv)_$MODE
D=/tmp/r10uvm94_armwd/$KEY
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
LEAF=$(basename "$SRC")
cd "$D" || exit 9
SLFLAG=""; OURFLAG=""
if [ "$MODE" = elab ]; then SLFLAG="-elabuhdm"; OURFLAG="-elabuhdm"; fi
"$SURELOG" -parse -nocache $SLFLAG "$LEAF" >surelog.log 2>&1
if [ ! -f slpp_all/surelog.uhdm ]; then echo "$KEY SURELOG_FAIL"; tail -4 surelog.log; exit 5; fi
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed 1d > g.dump
line="$KEY: slErr=$(grep -cE '^\[(ERR|FAT)' surelog.log; true)"
for tag in pris pat; do
  bin=$PRI; [ $tag = pat ] && bin=$PAT
  "$bin" $OURFLAG "$LEAF" -o $tag.uhdm > $tag.log 2>&1; rc=$?
  if [ ! -f $tag.uhdm ]; then line="$line $tag=NO_OUTPUT(rc=$rc)"; continue; fi
  "$DUMP" $tag.uhdm 2>/dev/null | sed 1d > $tag.dump
  res=$("$CMP" slpp_all/surelog.uhdm $tag.uhdm >$tag.cmp 2>&1 && echo CMP_EQUAL || echo CMP_NE)
  hd=$(grep -c '^LHS:' $tag.cmp; true)
  dd=$(diff g.dump $tag.dump | grep -cE '^[<>]'; true)
  line="$line $tag=rc$rc/$res/heads$hd/gdiff$dd"
done
if [ -f pris.dump ] && [ -f pat.dump ]; then
  if cmp -s pris.dump pat.dump; then line="$line MOVED=0"; else line="$line MOVED=$(diff pris.dump pat.dump | grep -cE '^[<>]'; true)"; fi
fi
echo "$line"
echo "WD=$D" >&2
