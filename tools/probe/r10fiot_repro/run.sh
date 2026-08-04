#!/bin/bash
# r10fiot arm runner: golden (surelog default-mode args) vs ours, CMP-projected diff.
# usage: run.sh <armfile.sv>
set -u
ARM=$1
B=$(basename "$ARM" .sv)
D=/tmp/r10fiot_arm/$B
rm -rf "$D"; mkdir -p "$D"
cp "$ARM" "$D/"
SL=$HOME/git-repos/Surelog/build/bin/surelog
SU=${SLANG_UHDM:?set SLANG_UHDM to the slang-uhdm binary}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
( cd "$D" && "$SL" -parse -mt 0 -mp 0 -o "$D/sl" "$B.sv" > "$D/sl.log" 2>&1 )
G=$(ls "$D"/sl/slpp_all/*.uhdm 2>/dev/null | head -1)
( cd "$D" && "$SU" "$B.sv" --single-unit -o "$D/ours.uhdm" > "$D/su.log" 2>&1 )
norm() {
  sed -e 's/, line:[0-9]*:[0-9]*, endln:[0-9]*:[0-9]*//g' \
      -e 's/, line:[0-9]*:[0-9]*//g' \
      -e '/|vpiRef[A-Za-z]*No:/d' \
      -e '/|vpiFullName:/d' \
      -e '/|vpiFile:/d' \
      -e '/|vpiColumnNo:/d' -e '/|vpiLineNo:/d' \
      -e '/|vpiEndLineNo:/d' -e '/|vpiEndColumnNo:/d' \
      -e 's|, file:[^,]*,|,|' "$1"
}
if [ -n "$G" ]; then "$DUMP" "$G" > "$D/g.txt" 2>&1; norm "$D/g.txt" | tail -n +2 > "$D/gn.txt"; else echo "NO GOLDEN"; fi
if [ -f "$D/ours.uhdm" ]; then "$DUMP" "$D/ours.uhdm" > "$D/o.txt" 2>&1; norm "$D/o.txt" | tail -n +2 > "$D/on.txt"; else echo "NO OURS (see $D/su.log)"; fi
if [ -f "$D/gn.txt" ] && [ -f "$D/on.txt" ]; then
  diff "$D/gn.txt" "$D/on.txt" > "$D/n.diff"
  echo "$B: cmp-relevant residue lines: $(grep -c '^[<>]' "$D/n.diff")"
fi
echo "workdir $D"
