#!/bin/bash
# usage: wit6.sh <basename...>   -> "cmp rc" + "dump identical?" per witness
R=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_b2de9437-c1b-1/tools/probe/r10earl_repro
for B in "$@"; do
  bash "$R/run6.sh" "$B.sv" > /dev/null 2>&1
  RC=$(bash "$R/cmprc6.sh" "$B" | sed 's/cmp rc=//')
  bash "$R/dmp6.sh" "$B" > /dev/null 2>&1
  D=/tmp/r10earl6_rep/out_$B
  N=$(diff <(tail -n +2 "$D/g.dump") <(tail -n +2 "$D/o.dump") | grep -c '^[-+<>]')
  echo "$B  cmp_rc=$RC  dump_diff_lines=$N"
done
