#!/bin/bash
rel=$1; c=/tmp/v11u160_cases/$rel; tag=$(echo $rel | tr / _)
mkdir -p /tmp/v11u160_dsc/$tag && cp $c/dut.sv /tmp/v11u160_dsc/$tag/dut.sv
PBIN=${PBIN:-/tmp/v11u160_bin/their_pris.bin}; LBIN=${LBIN:-/tmp/v11u160_bin/their_law.bin}
out=""
for b in pris law; do
  bin=$PBIN; [ $b = law ] && bin=$LBIN
  r=$(/tmp/v11u160_ds1.sh /tmp/v11u160_dsc/$tag $bin /tmp/v11u160_dsw2_$b 2>&1 | tail -1 | python3 -c "import sys,ast; d=ast.literal_eval(sys.stdin.read()); print(d['verdict']+'['+d['differs']+']')" 2>/dev/null)
  out="$out $b=$r"
done
echo "$rel$out"
