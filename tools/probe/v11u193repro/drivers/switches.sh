#!/bin/bash
# switches.sh <out tsv> <case dirs...> : md5 of ours per env switch (ref.bin), plus pris/law, plus trace of law firings (ref)
. "$(dirname "$0")/env.sh" || exit 3
O=$1; shift; : > $O
SW="NONE R11U193_OFF R11V193_OFF R11U193_CASTLEAF_OFF R11U193_CASTTSNAME_OFF R11U193_SYSARGDEF_OFF R11U193_TERNFILL_OFF R11U193_UNSIZEDCLONE_OFF R11U193_NESTNAME_OFF R11U193_COPYORDER_OFF R11V193_NESTPKGQ_OFF R11V193_NESTSEL_OFF R11V193_UCRANGE_OFF"
for c in "$@"; do D=$(cd $c && pwd); v193_fenced "$D" && continue; T=/tmp/v11u193_sw_tmp/$$; mkdir -p $T; line="$D"
  for b in pris law; do rm -f $T/o.uhdm; (cd $D && $V193_BIN/$b.bin dut.sv --single-unit --nobuiltin -o $T/o.uhdm >/dev/null 2>&1); line="$line	$b=$(md5sum < $T/o.uhdm 2>/dev/null | cut -c1-8)"; done
  for s in $SW; do rm -f $T/o.uhdm; if [ $s = NONE ]; then (cd $D && $V193_BIN/ref.bin dut.sv --single-unit --nobuiltin -o $T/o.uhdm >/dev/null 2>&1); else (cd $D && env $s=1 $V193_BIN/ref.bin dut.sv --single-unit --nobuiltin -o $T/o.uhdm >/dev/null 2>&1); fi; line="$line	$s=$(md5sum < $T/o.uhdm 2>/dev/null | cut -c1-8)"; done
  rm -rf $T/tr; mkdir -p $T/tr; (cd $D && R11U193_TRACE=$T/tr $V193_BIN/ref.bin dut.sv --single-unit --nobuiltin -o $T/o.uhdm >/dev/null 2>&1)
  line="$line	fired=$(cat $T/tr/*.193 2>/dev/null | grep -v '^OUT' | awk '{print $1}' | sort -u | tr '\n' ',')"
  echo "$line" >> $O; done
