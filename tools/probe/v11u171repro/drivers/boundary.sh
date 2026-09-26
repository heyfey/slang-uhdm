#!/bin/bash
# boundary.sh : every tools/probe/**/dut.sv + tests/probe/**/dut.sv (fenced refused), pris vs fix2 bytes
source /tmp/v11u171_scr/env.sh
R=/tmp/wt_v11u171; OUT=/tmp/v11u171_bnd; mkdir -p $OUT
(cd $R && find tools/probe tests/probe -name dut.sv | grep -Pv "$FENCED_RE" | grep -v '/r11u171repro/' | sort) > $OUT/list.txt
one() {
  rel=$1; d=$(dirname $rel); k=$(echo $d | tr / _)
  o=$OUT/w/$k; mkdir -p $o; rm -f $o/p.uhdm $o/f.uhdm
  (cd /tmp/wt_v11u171/$d && timeout 120 /tmp/v11u171_bin/pris.bin dut.sv --single-unit --nobuiltin -o $o/p.uhdm >/dev/null 2>&1 </dev/null); rp=$?
  (cd /tmp/wt_v11u171/$d && timeout 120 /tmp/v11u171_bin/fix2.bin dut.sv --single-unit --nobuiltin -o $o/f.uhdm >/dev/null 2>&1 </dev/null); rf=$?
  if [ ! -s $o/p.uhdm ] && [ ! -s $o/f.uhdm ]; then v=NODB; elif cmp -s $o/p.uhdm $o/f.uhdm; then v=SAME; rm -rf $o; else v=MOVER; fi
  echo "$v $rel rp=$rp rf=$rf"
}
export -f one; export OUT
xargs -a $OUT/list.txt -P 3 -I{} bash -c 'one {}' > $OUT/result.txt 2>&1
echo "listed=$(wc -l < $OUT/list.txt) processed=$(wc -l < $OUT/result.txt) $(awk '{print $1}' $OUT/result.txt | sort | uniq -c | tr '\n' ' ')" > $OUT/summary.txt
