#!/usr/bin/env bash
# offbytes.sh <list of arm dirs file> <outdir> : fix binary with R11U120_OFF=1 vs pristine, probe flags and downstream flags
set -u
L=$1; O=$2; mkdir -p $O
FIX=${FIX:-/tmp/v11u120_bin/fix1.bin}; PRI=/tmp/v11u120_bin/pri.bin
n=0; same=0; while read -r a <&3; do n=$((n+1)); k=$(echo "$a" | md5sum | cut -c1-12); d=$O/$k; rm -rf $d; mkdir -p $d
 (cd "$a" && R11U120_OFF=1 $FIX dut.sv --single-unit --nobuiltin -o $d/f.uhdm >/dev/null 2>&1; echo $? > $d/f.rc)
 (cd "$a" && $PRI dut.sv --single-unit --nobuiltin -o $d/p.uhdm >/dev/null 2>&1; echo $? > $d/p.rc)
 (cd "$a" && R11U120_OFF=1 $FIX -DSYNTHESIS dut.sv --single-unit --nobuiltin --filterprotected -o $d/fd.uhdm >/dev/null 2>&1; echo $? > $d/fd.rc)
 (cd "$a" && $PRI -DSYNTHESIS dut.sv --single-unit --nobuiltin -o $d/pd.uhdm >/dev/null 2>&1; echo $? > $d/pd.rc)
 if cmp -s $d/f.uhdm $d/p.uhdm && cmp -s $d/fd.uhdm $d/pd.uhdm && [ "$(cat $d/f.rc)" = "$(cat $d/p.rc)" ] && [ "$(cat $d/fd.rc)" = "$(cat $d/pd.rc)" ]; then same=$((same+1)); else echo "MOVED $a"; fi
done 3< "$L"
echo "ARMS=$n SAME=$same"
