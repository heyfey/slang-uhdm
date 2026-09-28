#!/bin/bash
# dsall.sh <state>...: dscase.py over every case of this directory per state; evidence/downstream/cases_<state>.txt
source "$(dirname "$0")/env.sh" || exit 2
cd $R199_DIR
for s in "$@"; do python3 drivers/dscase.py $s $(find cases -name dut.sv -printf '%h\n' | sort) > evidence/downstream/cases_$s.txt 2>&1; done
echo DSALL_DONE >> evidence/downstream/cases_$s.txt
