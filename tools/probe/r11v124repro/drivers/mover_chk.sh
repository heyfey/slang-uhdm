#!/bin/bash
# mover_chk.sh <corpus> <relpath>
c=$1; p=$2; d=$(dirname $p)
g=$(grep -o 'golden cache hit [^)]*' /tmp/v11u124_wdL/$c/$d/cmds.txt | awk '{print $4}')/golden.uhdm
if ! $UHDM_CMP $g /tmp/v11u124_wdP/$c/$p >/dev/null 2>&1; then
  pc=$($UHDM_CMP $g /tmp/v11u124_wdP/$c/$p 2>&1 | wc -l); lc=$($UHDM_CMP $g /tmp/v11u124_wdL/$c/$p 2>&1 | wc -l)
  echo "$c $d STAGE1 cmpP=$pc cmpL=$lc"; exit 0; fi
echo "$c $d $(python3 /tmp/v11u124_drv/pathchk.py $g /tmp/v11u124_wdP/$c/$p /tmp/v11u124_wdL/$c/$p | head -13 | tr '\n' ' ')"
