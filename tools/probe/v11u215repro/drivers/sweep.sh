#!/bin/bash
# v11u215: full gate sweep with a frozen binary. usage: sweep.sh <bin> <workdir> [corpora]
. "$(dirname "${BASH_SOURCE[0]:-$0}")/env.sh" || exit 3
export SLANG_UHDM=$1 STRICT_CMP=/tmp/v11u215_bin/uhdm-strictcmp
WD=$2; C=${3:-probe surelog uhdm2rtlil downstream}
cd $WT
bash tests/sweep.sh --jobs 3 --workdir $WD --corpus "$C"
echo "sweep rc=$?"
