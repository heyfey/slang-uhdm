#!/bin/bash
# bytes.sh <out.tsv> <root dir>...: every dut.sv under the roots (subdirectories included; the file list is read on
# fd 3, children get </dev/null), exported by the pristine and the law binary; prints rel path, rc of each, and
# same/MOVED.  Asserts PROCESSED == LISTED.  Scratch /tmp/r11u164_bytes.  Evidence cases only (no corpus source).
O=$1; shift; T=/tmp/r11u164_bytes; mkdir -p $T; : > $O
find "$@" -name dut.sv | sort > $T/list; L=$(wc -l < $T/list); P=0
while read -r f <&3; do
  d=$(dirname $f)
  rm -f $T/p.uhdm $T/l.uhdm
  (cd $d && timeout 120 $PRIS dut.sv --single-unit --nobuiltin -o $T/p.uhdm </dev/null >/dev/null 2>&1); rp=$?
  (cd $d && timeout 120 $LAW dut.sv --single-unit --nobuiltin -o $T/l.uhdm </dev/null >/dev/null 2>&1); rl=$?
  if [ -f $T/p.uhdm ] && [ -f $T/l.uhdm ] && cmp -s $T/p.uhdm $T/l.uhdm; then s=same; elif [ ! -f $T/p.uhdm ] && [ ! -f $T/l.uhdm ]; then s=nodb; else s=MOVED; fi
  printf '%s\t%s\t%s\t%s\n' "${d#*/tools/probe/}" $rp $rl $s >> $O; P=$((P+1))
done 3< $T/list
echo "PROCESSED=$P LISTED=$L"
