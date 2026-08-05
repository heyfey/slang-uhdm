#!/bin/bash
# usage: wit4.sh <basename...>   -> "cmp rc" + "dump identical?" per witness
R=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_e2dd1bad-344-1/tools/probe/r10earl_repro
for B in "$@"; do
  bash "$R/run5.sh" "$B.sv" > /dev/null 2>&1
  RC=$(bash "$R/cmprc5.sh" "$B" | sed 's/cmp rc=//')
  bash "$R/dmp5.sh" "$B" > /dev/null 2>&1
  D=/tmp/r10earl5_rep/out_$B
  N=$(diff <(tail -n +2 "$D/g.dump") <(tail -n +2 "$D/o.dump") | grep -c '^[-+<>]')
  echo "$B  cmp_rc=$RC  dump_diff_lines=$N"
done
