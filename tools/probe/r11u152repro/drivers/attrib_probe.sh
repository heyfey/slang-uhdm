#!/bin/bash
# attrib_probe.sh <law_sweep.log> <outdir>: the switch attribution of every probe case the law sweep
# moved (CONVERSION or CHANGE), one check_probe run per r11u152 switch (law binary + that switch).
L=$1; O=$2; mkdir -p $O
cases=$(sed -n '/== probe vs/,/regressions=/p' $L | awk '/^(CONVERSION|CHANGE)/{print $2}' | sort -u)
re="^($(echo $cases | sed 's/ /|/g; s/\./\\./g'))$"
echo "$cases" > $O/cases.txt
cd $(dirname $0)/../../../..
export SLANG_UHDM=${LAW:-/tmp/r11u152_bin/law2.bin}
for sw in NONE R11U152_C3_OFF R11U152_GENLPOPTS_OFF R11U152_FOLDCHAIN_OFF R11U152_TPELEMPAT_OFF \
          R11U152_PKGELEMPAT_OFF R11U152_ELEMALIAS_OFF R11U152_TPOVRSTRUCT_OFF R11U152_GENCASE_OFF \
          R11U152_DLYREAL_OFF R11U152_CGINITEND_OFF R11U152_CLSVARINIT_OFF R11U152_CLSNESTNAME_OFF \
          R11U152_CLSPANOFILE_OFF R11U152_PKGLEAFLOC_OFF R11U152_OFF; do
  ( [ $sw = NONE ] || export $sw=1
    python3 scripts/check_probe.py --jobs 2 --filter "$re" --out $O/p_$sw.csv --workdir $O/wd_$sw > $O/p_$sw.log 2>&1 )
done
