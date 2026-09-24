#!/bin/bash
# lawsweeps.sh SW... : the pass-dependent rows (conv lists) under one switch off at a time (frozen pristine binary)
source /tmp/r11u141_drv/env.sh
cd /tmp/wt_r11u141
SRE="^($(paste -sd'|' /tmp/r11u141_conv_surelog.txt))\$"
URE="^($(paste -sd'|' /tmp/r11u141_conv_uhdm2rtlil.txt))\$"
PRE="^($(sed 's/[.]/\\./g' /tmp/r11u141_conv_probe.txt | paste -sd'|'))\$"
for spec in "$@"; do
  tag=${spec%%=*}; envs=${spec#*=}
  wd=/tmp/r11u141_ls/$tag; rm -rf $wd; mkdir -p $wd
  ( for kv in ${envs//,/ }; do [ -n "$kv" ] && export $kv=1; done
    env | grep -E '^R11[UV]1' > $wd/ENV
    python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$SRE" --out $wd/surelog.csv --workdir $wd/surelog > $wd/log 2>&1
    python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$URE" --out $wd/uhdm2rtlil.csv --workdir $wd/uhdm2rtlil >> $wd/log 2>&1
    python3 scripts/check_probe.py --jobs 3 --filter "$PRE" --out $wd/probe.csv --workdir $wd/probe >> $wd/log 2>&1 )
  echo "$tag done $(date -Is)"
done
