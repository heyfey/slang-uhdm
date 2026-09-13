#!/bin/bash
# r11u8 — the stringify grid: golden vs ours, string constants only.
# Usage: grid8.sh <slang-uhdm binary> [arm...]      (default: every g*/ b*/ arm)
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
BIN=${1:?slang-uhdm binary}
shift
HERE=$(cd "$(dirname "$0")" && pwd)
ARMS=${*:-$(cd "$HERE" && ls -d g? b? 2>/dev/null)}
for a in $ARMS; do
  d="$HERE/$a"
  [ -f "$d/dut.sv" ] || { echo "$a NO-ARM"; continue; }
  (cd "$d" && $SL -parse -nobuiltin -nocache -sv dut.sv > sl.log 2>&1)
  slrc=$?
  (cd "$d" && "$BIN" dut.sv --single-unit --nobuiltin -o ours.uhdm > ours.log 2>&1)
  ourc=$?
  $CMP "$d/slpp_all/surelog.uhdm" "$d/ours.uhdm" > "$d/cmp.out" 2> "$d/cmp.err"
  cmprc=$?
  echo "=== $a  surelog_rc=$slrc ours_rc=$ourc cmp_rc=$cmprc cmplines=$(wc -l < "$d/cmp.out") heads=$(grep -c '^LHS:' "$d/cmp.err"; true)"
  paste <($DUMP "$d/slpp_all/surelog.uhdm" 2>/dev/null | grep -E '^ *\|STRING:' | sed 's/^ *|STRING://') \
        <($DUMP "$d/ours.uhdm" 2>/dev/null | grep -E '^ *\|STRING:' | sed 's/^ *|STRING://') \
    | sed 's/^/    GOLD[/; s/\t/]  OURS[/; s/$/]/'
done
exit 0
