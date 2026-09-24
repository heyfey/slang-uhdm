#!/usr/bin/env bash
source /tmp/v11u131_drv/env.sh
unset GOLDEN_DEFER
cd /tmp/wt_v11u131pris && SLANG_UHDM=/tmp/v11u131_bin/pristine tests/sweep.sh --jobs 3 --workdir /tmp/v11u131_wdP --corpus "probe surelog uhdm2rtlil" > /tmp/v11u131_sweepP.log 2>&1; echo "P rc=$?" >> /tmp/v11u131_sweeps_done.txt
cd /tmp/wt_v11u131 && SLANG_UHDM=/tmp/v11u131_bin/law tests/sweep.sh --jobs 3 --workdir /tmp/v11u131_wdL --corpus "probe surelog uhdm2rtlil" > /tmp/v11u131_sweepL.log 2>&1; echo "L rc=$?" >> /tmp/v11u131_sweeps_done.txt
cd /tmp/wt_v11u131 && SLANG_UHDM=/tmp/v11u131_bin/law tests/sweep.sh --jobs 3 --workdir /tmp/v11u131_wdD --corpus downstream > /tmp/v11u131_sweepD.log 2>&1; echo "D rc=$?" >> /tmp/v11u131_sweeps_done.txt
