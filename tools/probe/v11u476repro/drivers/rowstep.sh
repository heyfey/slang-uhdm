#!/bin/bash
# rowstep.sh <tag> <slang.uhdm>: uhdm-cmp lines, the sister's param_assign face simulated on a COPY
# (pass 474's addpa.cpp), then the strict walk's first divergence (measurement only)
source /tmp/v11u476_env.sh || exit 1
T=$1; f=$2
G=/home/heyfey/.cache/slang-uhdm-goldens/0445655ee703/50a224b0134d47ab3870/golden.uhdm
echo "$T cmp=$($UHDM_CMP $G $f 2>&1 | wc -l)"
/tmp/v11u476_tools/addpa $f /tmp/v11u476_pa_$T.uhdm | tail -1
echo "$T simulated cmp=$($UHDM_CMP $G /tmp/v11u476_pa_$T.uhdm 2>&1 | wc -l)"
timeout 1800 $STRICTCMP --max ${MAX:-4} $G /tmp/v11u476_pa_$T.uhdm 2>&1 | tail -${TAILN:-12}
