#!/bin/bash
# r11v11u8 — INDEPENDENT grid instrument. Usage: vgrid.sh <binary> <tag> [arm...]
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
BIN=${1:?binary}; TAG=${2:?tag}; shift 2
HERE=$(cd "$(dirname "$0")" && pwd)
ARMS=${*:-$(cd "$HERE" && ls -d g? b? v? 2>/dev/null)}
for a in $ARMS; do
  d="$HERE/$a"; [ -f "$d/dut.sv" ] || { echo "$a NO-ARM"; continue; }
  (cd "$d" && $SL -parse -nobuiltin -nocache -sv dut.sv > sl.$TAG.log 2>&1); slrc=$?
  (cd "$d" && "$BIN" dut.sv --single-unit --nobuiltin -o ours.$TAG.uhdm > ours.$TAG.log 2>&1); ourc=$?
  $CMP "$d/slpp_all/surelog.uhdm" "$d/ours.$TAG.uhdm" > "$d/cmp.$TAG.out" 2> "$d/cmp.$TAG.err"; cmprc=$?
  hd=$(grep -c '^LHS:' "$d/cmp.$TAG.err"; true)
  echo "=== $a [$TAG] slrc=$slrc ourrc=$ourc cmprc=$cmprc cmplines=$(wc -l < "$d/cmp.$TAG.out") heads=$hd"
  $DUMP "$d/slpp_all/surelog.uhdm" 2>/dev/null | grep -oE '\|STRING:.*' | sed 's/^/    G |/' | sort > "$d/gs.$TAG.txt"
  $DUMP "$d/ours.$TAG.uhdm"        2>/dev/null | grep -oE '\|STRING:.*' | sed 's/^/    O |/' | sort > "$d/os.$TAG.txt"
  diff <(sed 's/^    G //' "$d/gs.$TAG.txt") <(sed 's/^    O //' "$d/os.$TAG.txt") \
     | sed 's/^/    STRDIFF /' | head -40
done
exit 0
