#!/bin/bash
# swm <case> : one line per config: case view config md5 fires ; configs: pris, fix3, fix3+each switch
source $(dirname "${BASH_SOURCE[0]}")/env.sh || exit 9
c=$1; echo "$c" | grep -qP "$FENCED_RE" && { echo "FENCE $c"; exit 4; }
rel=$(echo $c | sed -e "s#.*/tools/probe/##"); W=/tmp/v11u192_swm/$rel; mkdir -p $W
for v in d e; do
  for cfg in pris fix3 R11U192_OFF R11U192_PSOWNER_OFF R11U192_GFREPL_OFF R11U192_PROCPS_OFF R11U192_TFPS_OFF R11U192_NDAPS_OFF R11U192_PSVERB_OFF R11U192_QBSPAN_OFF R11U192_PATTD_OFF R11V192_WHOLELHS_OFF; do
    b=${LAWBIN:?export LAWBIN}; envs=""; [ $cfg = pris ] && b=${PRISBIN:?export PRISBIN}; case $cfg in R11*) envs="$cfg=1";; esac
    o=$W/$v.$cfg.uhdm; rm -f $o; rm -rf $W/$v.$cfg.tr; mkdir -p $W/$v.$cfg.tr
    (cd $c && env $envs R11U192_TRACE=$W/$v.$cfg.tr $b $([ $v = e ] && echo --elabuhdm) dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1)
    f=$(cat $W/$v.$cfg.tr/* 2>/dev/null | grep -v '^OUT' | sort -u | tr '\n' ,)
    echo "$rel $v $cfg $( [ -s $o ] && md5sum < $o | cut -c1-10 || echo NONE) ${f:-none}"
  done
done
