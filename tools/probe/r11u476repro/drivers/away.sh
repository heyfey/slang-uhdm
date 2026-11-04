#!/bin/bash
# away.sh <listfile> <outfile> <bin...>: for every dut.sv path in <listfile> (absolute or repo-relative,
# read on fd 3), run each binary on it in its own dir (dut.sv --single-unit --nobuiltin), print
# "<path> <rc>:<md5> ..." per binary; outputs under /tmp/r11u476_away/<binary tag>/<path>
L=$1; O=$2; shift 2
ROOT=/home/heyfey/git-repos/slang-uhdm
: > "$O"
run1() {
  f=$1; shift; d=$(dirname "$f"); [ "${d:0:1}" = / ] || d=$ROOT/$d
  line="$f"
  for b in "$@"; do
    t=$(basename "$b"); out=/tmp/r11u476_away/$t$d.uhdm; mkdir -p "$(dirname "$out")"; rm -f "$out"
    (cd "$d" && timeout 120 "$b" dut.sv --single-unit --nobuiltin -o "$out" >/dev/null 2>&1 </dev/null); rc=$?
    line="$line $rc:$( [ -f "$out" ] && md5sum < "$out" | cut -c1-12 || echo none)"
  done
  echo "$line"
}
export -f run1; export ROOT
xargs -a "$L" -P 6 -I{} bash -c 'run1 "$@"' _ {} "$@" >> "$O"
