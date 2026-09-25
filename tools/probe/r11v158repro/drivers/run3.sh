#!/bin/bash
# run3.sh <GW> <cases...>: pris / law / fix on each case
export GW=$1; shift
for d in "$@"; do for b in pris law ${FIXB:-fix2}; do /tmp/v11u158_grid.sh $d /tmp/v11u158_bin/$b.bin $b; done; done
