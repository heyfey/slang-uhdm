#!/bin/bash
# away.sh <dir relative to /tmp/wt_v11u491>...: rc and md5 on pristine, law, verified
for p in "$@"; do d=/tmp/wt_v11u491/$p; W=/tmp/v11u491_away/$p; mkdir -p "$W"
F=dut.sv; [ -f "$d/FILES" ] && F=$(cat "$d/FILES")
out="$p"
for t in pristine law verified; do bin=/tmp/v11u491_bin/$t; [ -x "$bin" ] || exit 1
  rm -f "$W/$t.uhdm"; (cd "$d" && timeout 300 "$bin" $F --single-unit --nobuiltin -o "$W/$t.uhdm" > "$W/$t.log" 2>&1 </dev/null); rc=$?
  out="$out $t=$rc:$(md5sum < "$W/$t.uhdm" 2>/dev/null | cut -c1-8)"; done
echo "$out"; done
