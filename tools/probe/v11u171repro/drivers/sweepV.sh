#!/bin/bash
source /tmp/v11u171_scr/env.sh
export SLANG_UHDM=/tmp/v11u171_bin/fix2.bin
cd /tmp/wt_v11u171 && bash tests/sweep.sh --jobs 3 --workdir /tmp/v11u171_swV --corpus "probe surelog uhdm2rtlil" > /tmp/v11u171_sweep_V.log 2>&1
echo "swV rc=$?" >> /tmp/v11u171_sweeps_done.txt
bash tests/sweep.sh --jobs 3 --workdir /tmp/v11u171_swV --corpus downstream > /tmp/v11u171_sweepds_V.log 2>&1
echo "dsV rc=$?" >> /tmp/v11u171_sweeps_done.txt
