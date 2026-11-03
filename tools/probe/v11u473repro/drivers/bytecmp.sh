#!/bin/bash
# bytecmp.sh <list> <out>: pristine vs law bytes and exit code per case dir (no golden); cwd tools/probe of the verifier worktree
P=/tmp/v11u473_bin/pristine; L=/tmp/v11u473_bin/law
[ -x "$P" ] && [ -x "$L" ] || exit 1
cd /tmp/wt_v11u473/tools/probe
while read -u 3 c; do
  W=/tmp/v11u473_bc/$c; mkdir -p "$W"; rm -f "$W"/p.uhdm "$W"/l.uhdm
  (cd "$c" && "$P" dut.sv --single-unit --nobuiltin -o "$W/p.uhdm" >/dev/null 2>&1 </dev/null); rp=$?
  (cd "$c" && "$L" dut.sv --single-unit --nobuiltin -o "$W/l.uhdm" >/dev/null 2>&1 </dev/null); rl=$?
  if cmp -s "$W/p.uhdm" "$W/l.uhdm"; then s=SAME; else s=MOVED; fi
  echo "$c rp=$rp rl=$rl $s"
done 3< "$1" > "$2" 2>&1
echo DONE >> "$2"
