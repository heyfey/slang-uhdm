#!/bin/bash
# switches.sh <out.txt> : every switch of the pass alone on the final binary over cases/; per case, which switches
# restore the pristine bytes (grid tags pris / final must exist: drivers/grid.sh).
set -u; D=/tmp/wt_r11u176/tools/probe/r11u176repro/drivers; G=/tmp/r11u176_scratch/gridout
SW="R11U175_FSPAN_OFF R11U176_CASTCLONE_OFF R11U176_PROGLCLOC_OFF R11U176_PROGMPDEF_OFF R11U176_GENMPLOC_OFF R11U176_GENPLAINLOC_OFF R11U176_GENPLAINVARS_OFF R11U176_PROGVIEW_OFF R11U176_QUALFORMAL_OFF R11U176_CLSMETHOD_OFF R11U176_DEFTOPSPLIT_OFF R11U176_TDKEY_OFF R11U176_TDTIE_OFF R11U176_UDPLV_OFF R11U176_ELSEBEGIN_OFF R11U176_GENARR_OFF"
for s in $SW; do $D/grid.sh sw_$s /tmp/r11u176_bin/final4.bin $s=1 > /dev/null; done
for d in $G/*.final4; do b=${d%.final4}; n=$(basename $b); cmp -s $d/ours.uhdm $b.pris/ours.uhdm && continue
  r=""; m=""; for s in $SW; do if cmp -s $b.sw_$s/ours.uhdm $b.pris/ours.uhdm; then r="$r $s"; elif ! cmp -s $b.sw_$s/ours.uhdm $d/ours.uhdm; then m="$m $s"; fi; done
  echo "$n restores:${r:- none} moves:${m:- none}"; done > $1
