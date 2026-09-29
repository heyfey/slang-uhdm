#!/bin/bash
# v11u215: gate sweep from a given worktree (its own results/ baselines). usage: sweeph.sh <worktree> <bin> <workdir> [corpora]
. "$(dirname "${BASH_SOURCE[0]:-$0}")/env.sh" || exit 3
export SLANG_UHDM=$2 STRICT_CMP=/tmp/v11u215_bin/uhdm-strictcmp
cd $1; bash tests/sweep.sh --jobs 3 --workdir $3 --corpus "${4:-probe surelog uhdm2rtlil downstream}"
echo "sweep rc=$?"
