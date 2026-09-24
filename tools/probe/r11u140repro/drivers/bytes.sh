#!/bin/bash
# bytes.sh <binA> <binB> <outdir> <dir>... : every dut.sv under the dirs exported by both binaries
# (probe command line); prints SAME/MOVED/FAIL per case and a tally. Measurement only (r11u140).
A=$1; B=$2; O=$3; shift 3; mkdir -p $O
same=0; moved=0; fail=0; n=0
while IFS= read -r f <&3; do
  c=$(dirname "$f"); k=$(echo "$c" | sed 's#.*/tools/probe/##; s#.*/tests/probe/##; s#/#__#g')
  rm -f $O/$k.a.uhdm $O/$k.b.uhdm
  (cd "$c" && "$A" dut.sv --single-unit --nobuiltin -o $O/$k.a.uhdm </dev/null >/dev/null 2>&1); ra=$?
  (cd "$c" && "$B" dut.sv --single-unit --nobuiltin -o $O/$k.b.uhdm </dev/null >/dev/null 2>&1); rb=$?
  n=$((n+1))
  if [ ! -s $O/$k.a.uhdm ] || [ ! -s $O/$k.b.uhdm ]; then
    if [ "$ra" = "$rb" ] && [ ! -s $O/$k.a.uhdm ] && [ ! -s $O/$k.b.uhdm ]; then echo "NODB-BOTH $k rc=$ra"; same=$((same+1)); else echo "FAIL $k rcA=$ra rcB=$rb"; fail=$((fail+1)); fi
  elif cmp -s $O/$k.a.uhdm $O/$k.b.uhdm; then echo "SAME $k"; same=$((same+1))
  else echo "MOVED $k"; moved=$((moved+1)); fi
done 3< <(for d in "$@"; do find "$d" -name dut.sv; done | sort)
echo "TOTAL $n SAME $same MOVED $moved FAIL $fail"
