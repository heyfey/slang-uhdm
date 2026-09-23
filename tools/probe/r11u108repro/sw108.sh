#!/bin/bash
# sw108.sh <out-root> <law-binary> <pristine-binary> <grid-dir>...
# SWITCH CHECK: every dut.sv arm under each grid dir is compiled by the law
# binary with R11U108_OFF=1, R11U108_TPPAV_OFF=1, R11U108_PKGTDMEM_OFF=1 and by
# the pristine binary.  Prints per arm which runs are byte-identical to pristine.
OUT=${1:?}; LAW=${2:?}; PRI=${3:?}; shift 3
mkdir -p "$OUT"; N=0
for G in "$@"; do
  while read -r rel <&3; do
    arm=$(dirname "${rel#./}"); key=$(echo "$G/$arm" | sed 's#[/.]#_#g'); w="$OUT/$key"; mkdir -p "$w"
    run(){ (cd "$G/$arm" && env $2 timeout 300 "$1" dut.sv --single-unit --nobuiltin -o "$w/$3.uhdm" </dev/null >/dev/null 2>&1); }
    run "$PRI" X=1 pris; run "$LAW" X=1 law; run "$LAW" R11U108_OFF=1 off; run "$LAW" R11U108_TPPAV_OFF=1 offa; run "$LAW" R11U108_PKGTDMEM_OFF=1 offb
    r=""; for t in law off offa offb; do cmp -s "$w/pris.uhdm" "$w/$t.uhdm" && r="$r $t=P" || r="$r $t=M"; done
    echo "$G/$arm$r"; N=$((N+1))
  done 3< <(cd "$G" && find . -name dut.sv | sort)
done
echo "PROCESSED=$N"
