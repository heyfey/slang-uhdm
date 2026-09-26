#!/bin/bash
# offbytes.sh <pristine> <law> <outdir> <case dir>...: every dut.sv under the given dirs exported by
# the pristine binary, the law binary, and the law binary with R11U169_OFF=1; prints per case whether
# law == pristine and off == pristine (bytes), and the totals.  Scratch keyed on the relative path.
P=$1; L=$2; O=$3; shift 3; mkdir -p $O
find "$@" -name dut.sv | sort > $O/list.txt
exec 3< $O/list.txt
n=0; lawmv=0; offmv=0; nodb=0
while read -r f <&3; do
  d=$(dirname $f); k=$(echo $d | sed 's#.*/tools/probe/##; s#.*/tests/probe/#tp/#; s#/#__#g')
  for t in P L O; do rm -f $O/$k.$t.uhdm; done
  (cd $d && $P dut.sv --single-unit --nobuiltin -o $O/$k.P.uhdm </dev/null >/dev/null 2>&1)
  (cd $d && $L dut.sv --single-unit --nobuiltin -o $O/$k.L.uhdm </dev/null >/dev/null 2>&1)
  (cd $d && R11U169_OFF=1 $L dut.sv --single-unit --nobuiltin -o $O/$k.O.uhdm </dev/null >/dev/null 2>&1)
  n=$((n+1))
  if [ ! -s $O/$k.P.uhdm ]; then nodb=$((nodb+1)); [ -s $O/$k.L.uhdm ] && echo "LAWDB_ONLY $k"; continue; fi
  cmp -s $O/$k.P.uhdm $O/$k.L.uhdm || { lawmv=$((lawmv+1)); echo "LAW_MOVER $k"; }
  cmp -s $O/$k.P.uhdm $O/$k.O.uhdm || { offmv=$((offmv+1)); echo "OFF_MOVER $k"; }
  rm -f $O/$k.P.uhdm $O/$k.L.uhdm $O/$k.O.uhdm
done
echo "cases=$n no_database=$nodb law_movers=$lawmv off_movers=$offmv"
