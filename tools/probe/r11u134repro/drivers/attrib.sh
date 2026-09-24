#!/bin/bash
# attrib.sh <movers_class.tsv> <which: all|unpred> <switch list...>  -> per switch sweep dirs under /tmp/r11u134_att/<switch>/<corpus>
source /tmp/r11u134_env.sh; export SLANG_UHDM=/tmp/r11u134_bin/law17
M=$1; which=$2; shift 2
cd /tmp/wt_r11u134
for c in surelog uhdm2rtlil; do
  if [ $which = all ]; then names=$(awk -F'\t' -v c=$c '$1==c && $3!=""{print $3}' $M | sort -u | paste -sd'|')
  else names=$(awk -F'\t' -v c=$c '$1==c && $6!="predicted" && $3!=""{print $3}' $M | sort -u | paste -sd'|'); fi
  [ -z "$names" ] && continue
  for s in "$@"; do
    A=/tmp/r11u134_att/$s/$c; rm -rf $A; mkdir -p $A
    if [ $s = OFF ]; then ev=R11U134_OFF=1; else ev=R11U134_${s}_OFF=1; fi
    env $ev python3 scripts/verify_golden.py --corpus $c --mode both --jobs 3 --out $A.csv --workdir $A --filter "^($names)\$" >/dev/null 2>&1
  done
done
