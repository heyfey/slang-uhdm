#!/bin/bash
# (copy of r11u171repro/drivers/boundary.sh with this pass's paths)
# boundary.sh <out dir> : every tools/probe/**/dut.sv outside this pass (tests/probe is the gate sweep's probe stage), exported by the
# pristine and the law binary (`dut.sv --single-unit --nobuiltin`, children on </dev/null), the databases compared
# byte for byte; fenced paths refused (fail closed).  One line per case: SAME / MOVER / NODB.
set -u; O=$1; mkdir -p $O/db; : "${FENCED:?FENCED unset}"; [ "$(echo $FENCED | wc -w)" = 4 ] || exit 3
R=/tmp/wt_r11u176; P=/tmp/r11u176_bin/pris.bin; L=/tmp/r11u176_bin/final4.bin
fre=$(echo $FENCED | sed 's/ /\\|/g')
find $R/tools/probe -name dut.sv -not -path '*/r11u176repro/*' | grep -vw "$fre" | sort > $O/list.txt
one() { d=$(dirname $1); k=$(echo $d | sed "s|$R/||; s|/|__|g")
  rm -f $O/db/$k.p.uhdm $O/db/$k.l.uhdm
  (cd $d && timeout 120 $P dut.sv --single-unit --nobuiltin -o $O/db/$k.p.uhdm >/dev/null 2>&1 </dev/null)
  (cd $d && timeout 120 $L dut.sv --single-unit --nobuiltin -o $O/db/$k.l.uhdm >/dev/null 2>&1 </dev/null)
  if [ ! -s $O/db/$k.p.uhdm ] && [ ! -s $O/db/$k.l.uhdm ]; then echo "NODB $d"
  elif cmp -s $O/db/$k.p.uhdm $O/db/$k.l.uhdm; then echo "SAME $d"; rm -f $O/db/$k.p.uhdm $O/db/$k.l.uhdm
  else echo "MOVER $d"; fi; }
export -f one; export O R P L
xargs -a $O/list.txt -P 4 -I{} bash -c 'one {}' > $O/result.txt
echo "listed $(wc -l < $O/list.txt) processed $(wc -l < $O/result.txt)"; cut -d' ' -f1 $O/result.txt | sort | uniq -c
