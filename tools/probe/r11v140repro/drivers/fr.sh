#!/usr/bin/env bash
# fr.sh <case dir> [N]: first differing strict records, pristine then law
source /tmp/v11u140_scratch/env.sh
c=$(realpath ${1%/}); n=${2:-4}
g=/tmp/v11u140_gcache/$(md5sum $c/dut.sv|cut -c1-16).uhdm
for b in ${BINS:-pris law}; do echo "--- $b"; $STRICT_CMP --max $n $g $c/$b.uhdm 2>&1 | tail -n $((3*n+2)); done
