#!/bin/bash
# attrib.sh <movers file: name,mode per line>  -> for every r11u130 switch (and R11U130_OFF) re-run the law
# binary on the mover tests with ONLY that switch set; then per mover: which switches move its bytes
# away from the law sweep's (the laws that own it) and whether R11U130_OFF gives the pristine bytes.
source /tmp/r11u130_env.sh; export SLANG_UHDM=/tmp/r11u130_bin/law.bin
M=$1; A=/tmp/r11u130_att
names=$(cut -d, -f1 $M | sort -u | paste -sd'|')
cd /tmp/wt_r11u130
for s in OFF DEFNETLOC_OFF WILDSPAN_OFF CLSARGNET_OFF NETSIGN_OFF PVPARAM_OFF SUSIGN_OFF IFSUKW_OFF REDEFLINE_OFF INCNOTEXT_OFF GVTSFILE_OFF; do
  for c in surelog uhdm2rtlil; do
    env R11U130_$s=1 python3 scripts/verify_golden.py --corpus $c --mode both --jobs 3 --out $A/$s/$c.csv --workdir $A/$s/$c --filter "^($names)\$" >/dev/null 2>&1
  done
done
h(){ f=$(ls -d $1/$3/$2-* 2>/dev/null | head -1); [ -n "$f" ] && md5sum < $f/slang.uhdm | cut -c1-12 || echo none; }
while IFS=, read n m; do
  for c in surelog uhdm2rtlil; do
    L=$(h /tmp/r11u130_wdL/$c $n $m); [ "$L" = none ] && continue
    P=$(h /tmp/r11u130_wdP/$c $n $m); O=$(h $A/OFF/$c $n $m)
    by=""; for s in DEFNETLOC WILDSPAN CLSARGNET NETSIGN PVPARAM SUSIGN IFSUKW REDEFLINE INCNOTEXT GVTSFILE; do
      [ "$(h $A/${s}_OFF/$c $n $m)" != "$L" ] && by="$by $s"; done
    echo "$c/$n/$m	OFF=$([ "$O" = "$P" ] && echo pristine || echo DIFFERS)	laws:${by:- none}"
  done
done < $M
