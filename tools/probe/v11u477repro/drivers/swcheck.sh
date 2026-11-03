#!/bin/bash
# swcheck.sh <envassign> <reftag> <casedir>...: run verified with env, compare md5+rc to ref tag output
E=$1; REF=$2; shift 2
B=/tmp/v11u477_bin/verified; [ -x "$B" ] || exit 1
ok=0; bad=0
for c in "$@"; do c=$(realpath $c); W=/tmp/v11u477_runs$c; O=/tmp/v11u477_scr/sw.uhdm; rm -f $O
  (cd $c && env $E "$B" dut.sv --single-unit --nobuiltin -o $O > /dev/null 2>&1 </dev/null); rc=$?
  if [ "$(md5sum < $O)" = "$(md5sum < $W/$REF.uhdm)" ] && [ $rc = 0 ]; then ok=$((ok+1)); else bad=$((bad+1)); echo "MISMATCH $c rc=$rc"; fi
done; echo "$E vs $REF: same $ok, differ $bad"
