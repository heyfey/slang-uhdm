#!/bin/bash
# away1.sh <reldir under the worktree>: exit code + output md5 of pristine, law and verified (outputs deleted first)
c=/tmp/wt_v11u487/$1; W=/tmp/v11u487_away/$1; mkdir -p $W
F=dut.sv; [ -f "$c/FILES" ] && F=$(cat "$c/FILES")
r=""
for t in pristine law ver; do B=/tmp/v11u487_bin/$t
  rm -f $W/$t.uhdm; (cd $c && timeout 120 "$B" $F --single-unit --nobuiltin -o $W/$t.uhdm >/dev/null 2>&1 </dev/null); rc=$?
  m=$( [ -f $W/$t.uhdm ] && md5sum < $W/$t.uhdm | cut -c1-8 || echo none)
  r="$r $rc:$m"
done
echo "$1$r"
