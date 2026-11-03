#!/bin/bash
# away.sh <listfile of dirs relative to tools/probe> <outfile>: pristine vs law bytes and exit codes, absolute paths
P=/tmp/v11u470_bin/pristine; L=/tmp/v11u470_bin/law; B=/tmp/wt_v11u470/tools/probe
[ -x "$P" ] && [ -x "$L" ] || exit 1
while read d; do
  c=$B/$d; W=/tmp/v11u470_away/$d; mkdir -p "$W"; F=dut.sv; [ -f "$c/FILES" ] && F=$(cat "$c/FILES")
  rm -f "$W/p.uhdm" "$W/l.uhdm"
  (cd "$c" && timeout 120 "$P" $F --single-unit --nobuiltin -o "$W/p.uhdm" >/dev/null 2>&1 </dev/null); rp=$?
  (cd "$c" && timeout 120 "$L" $F --single-unit --nobuiltin -o "$W/l.uhdm" >/dev/null 2>&1 </dev/null); rl=$?
  mp=$(md5sum < "$W/p.uhdm" 2>/dev/null | cut -c1-8); ml=$(md5sum < "$W/l.uhdm" 2>/dev/null | cut -c1-8)
  s=SAME; [ "$mp" != "$ml" ] && s=MOVED; [ $rp != $rl ] && s=RCMOVE
  echo "$d rp=$rp rl=$rl $s"
done < "$1" > "$2"
