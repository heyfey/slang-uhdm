#!/bin/bash
# gridall.sh <tag> <bin> [ENV=VAL...]: every case under r11v167repro/cases through grid.sh
source ${ENVFILE:?export ENVFILE: the pin environment (SURELOG, UHDM_CMP, ..., FENCED)}
C=$(cd $(dirname $0)/../cases && pwd)
t=$1; b=$2; shift 2
for c in $(cd $C && ls -d */*/ | sed 's#/$##' | sort); do $(dirname $0)/grid.sh $C/$c $b $t "$@"; done
