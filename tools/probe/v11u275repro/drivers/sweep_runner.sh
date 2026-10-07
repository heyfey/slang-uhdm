#!/bin/bash
# v11u275 sweep runner: $1 = binary, $2 = workdir, $3 = corpus list
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export SLANG_UHDM=$1 STRICT_CMP=${STRICT_CMP:?export STRICT_CMP}
for t in "$SLANG_UHDM" "$SURELOG" "$UHDM_CMP" "$UHDM_DUMP" "$STRICT_CMP"; do [ -x "$t" ] || { echo "not executable: $t"; exit 2; }; done
cd "$(dirname "$0")/../../../.." && bash tests/sweep.sh --jobs 3 --workdir $2 --corpus "$3" > $2.log 2>&1; echo "exit=$?" >> $2.log
