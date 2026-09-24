# sw.sh <case dir> : fix1 with R11U130_OFF vs pristine bytes; fix1 with both R11V130 switches vs law bytes; fix1 per-law single switch vs fix1
source /tmp/v11u130_env.sh
d=$(realpath "$1"); w=/tmp/v11u130_sw/$(echo "$d" | md5sum | cut -c1-10); mkdir -p $w
run(){ rm -f $w/$1.uhdm; (cd $d && env $2 $3 dut.sv --single-unit --nobuiltin -o $w/$1.uhdm >/dev/null 2>&1); }
run P "X=1" /tmp/v11u130_bin/pris.bin
run L "X=1" /tmp/v11u130_bin/law.bin
run F "X=1" /tmp/v11u130_bin/fix1.bin
run O "R11U130_OFF=1" /tmp/v11u130_bin/fix1.bin
run V "R11V130_DEFNETVAR_OFF=1 R11V130_INCTAB_OFF=1" /tmp/v11u130_bin/fix1.bin
off=$(cmp -s $w/O.uhdm $w/P.uhdm && echo pristine || echo DIFF)
v=$(cmp -s $w/V.uhdm $w/L.uhdm && echo law || echo DIFF)
laws=""
for s in R11U130_DEFNETLOC_OFF R11U130_WILDSPAN_OFF R11U130_CLSARGNET_OFF R11U130_NETSIGN_OFF R11U130_PVPARAM_OFF R11U130_SUSIGN_OFF R11U130_IFSUKW_OFF R11U130_REDEFLINE_OFF R11U130_INCNOTEXT_OFF R11U130_GVTSFILE_OFF R11V130_DEFNETVAR_OFF R11V130_INCTAB_OFF; do
  run S "$s=1" /tmp/v11u130_bin/fix1.bin; cmp -s $w/S.uhdm $w/F.uhdm || laws="$laws ${s#R11}"
done
fp=$(cmp -s $w/F.uhdm $w/P.uhdm && echo F=P || echo F!=P)
echo "$(echo $d | sed 's#.*/tools/probe/##; s#/tmp/##') off=$off v=$v $fp laws:$laws"
