#!/bin/bash
# (v11u146) the setup file exports the tool paths of the brief and $FENCED; see ../README.md
# v11u146_sweep.sh <tree> <binary> <workdir>
. /tmp/v11u146_env.sh
export SLANG_UHDM=$2 STRICT_CMP=/tmp/v11u146_bin/uhdm-strictcmp
cd $1 && tests/sweep.sh --jobs 3 --workdir $3
echo "SWEEP_RC=$?"
