#!/bin/bash
# pavd28.sh <witness-basename>... -- run each witness, dump both databases, and
# print the pav28.py param_assign grid DELTA (golden vs ours) plus the row
# count, so a whole witness set is one screen.  POSITIVE CONTROL FIRST: the
# `-c` line must show a non-zero `withct`, otherwise the probe is broken and
# an empty delta means nothing.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_0498617d-9bf-1/tools/probe/r10earl_repro
for f in "$@"; do
  bash "$W/run28.sh" "$f.sv" > "/tmp/r10earl28_run_$f.log" 2>&1
  bash "$W/dmp28.sh" "$f" > /dev/null 2>&1
  D=/tmp/r10earl28_rep/out_$f
  echo "===== $f  ctl(golden): $(python3 "$W/pav28.py" -c "$D/g.dump")  ctl(ours): $(python3 "$W/pav28.py" -c "$D/o.dump")"
  python3 "$W/pav28.py" "$D/g.dump" > "/tmp/r10earl28_p_${f}_g.txt"
  python3 "$W/pav28.py" "$D/o.dump" > "/tmp/r10earl28_p_${f}_o.txt"
  n=$(diff "/tmp/r10earl28_p_${f}_g.txt" "/tmp/r10earl28_p_${f}_o.txt" | grep -c '^<')
  echo "  param_assign rows differing: $n"
  h=$(grep -m1 -A2 '^LHS:' "/tmp/r10earl28_run_$f.log" | tail -1 | cut -c1-110)
  if [ -z "$h" ]; then echo "  uhdm-cmp: EQUAL"; else echo "  uhdm-cmp HEAD(LHS=golden): $h"; fi
done
