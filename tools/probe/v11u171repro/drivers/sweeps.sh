#!/bin/bash
source /tmp/v11u171_scr/env.sh
run() { # tag bin wt
  export SLANG_UHDM=/tmp/v11u171_bin/$2
  cd /tmp/$3 && bash tests/sweep.sh --jobs 3 --workdir /tmp/v11u171_sw$1 --corpus "probe surelog uhdm2rtlil" > /tmp/v11u171_sweep_$1.log 2>&1
  echo "sw$1 rc=$?" >> /tmp/v11u171_sweeps_done.txt
}
run P pris.bin wt_v11u171pris &
run L law.bin wt_v11u171 &
wait
for t in P L; do
  export SLANG_UHDM=/tmp/v11u171_bin/$( [ $t = P ] && echo pris.bin || echo law.bin )
  w=$( [ $t = P ] && echo wt_v11u171pris || echo wt_v11u171 )
  cd /tmp/$w && bash tests/sweep.sh --jobs 3 --workdir /tmp/v11u171_sw$t --corpus downstream > /tmp/v11u171_sweepds_$t.log 2>&1
  echo "ds$t rc=$?" >> /tmp/v11u171_sweeps_done.txt
done
