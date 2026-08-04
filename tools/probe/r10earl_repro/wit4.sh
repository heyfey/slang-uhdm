#!/bin/bash
# usage: wit4.sh <basename...>   -> "cmp rc" + "dump identical?" per witness
R=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_428d55ab-870-1/tools/probe/r10earl_repro
for B in "$@"; do
  bash "$R/run4.sh" "$B.sv" > /dev/null 2>&1
  RC=$(bash "$R/cmprc4.sh" "$B" | sed 's/cmp rc=//')
  bash "$R/dmp4.sh" "$B" > /dev/null 2>&1
  D=/tmp/r10earl4_rep/out_$B
  N=$(diff <(tail -n +2 "$D/g.dump") <(tail -n +2 "$D/o.dump") | grep -c '^[-+<>]')
  echo "$B  cmp_rc=$RC  dump_diff_lines=$N"
done
