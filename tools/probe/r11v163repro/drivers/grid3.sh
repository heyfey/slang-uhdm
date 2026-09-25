# grid3.sh <casedir>: golden + pris + law + ver1 verdicts
source /tmp/v11u163_env.sh
/tmp/v11u163_grid.sh $1 > /tmp/v11u163_tmp_$$.txt
c=$(realpath $1); k=$(echo $c | sed 's#^/##; s#/#_#g'); w=/tmp/v11u163_g/$k; rm -f $w/ver1.uhdm
(cd $c && R11U163_TRACE=1 /tmp/v11u163_bin/ver1.bin dut.sv --single-unit --nobuiltin -o $w/ver1.uhdm 2>$w/ver1.log >/dev/null)
t=$(grep -c 'TRACE OVLOCALREF' $w/ver1.log)
v="none"; [ -s $w/ver1.uhdm ] && [ -s $w/golden.uhdm ] && v="cmp=$($UHDM_CMP $w/golden.uhdm $w/ver1.uhdm 2>&1 | wc -l) $($STRICT_CMP $w/golden.uhdm $w/ver1.uhdm | tail -1 | tr ' ' _)"
echo "$(cat /tmp/v11u163_tmp_$$.txt | sed 's/_objects//g') | ver1: $v fired=$t"; rm -f /tmp/v11u163_tmp_$$.txt
