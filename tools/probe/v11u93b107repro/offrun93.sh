#!/bin/bash
# v11u93_offrun.sh <grid-dir> <out-root> <tag> <binary> [ENV=VAL ...]: run ours only with env, rc recorded
GRID=$1; OUT=$2; tag=$3; bin=$4; shift 4
N=0; F=0
while read -r rel <&3; do
  arm=$(dirname "${rel#./}"); w="$OUT/$arm"; mkdir -p "$w"; rm -f "$w/$tag.uhdm"
  (cd "$GRID/$arm" && env "$@" timeout 300 "$bin" dut.sv --single-unit --nobuiltin -o "$w/$tag.uhdm" </dev/null > "$w/$tag.log" 2>&1); rc=$?
  [ $rc = 0 ] || { echo "RC $arm $rc"; F=$((F+1)); }
  N=$((N+1))
done 3< <(cd "$GRID" && find . -name dut.sv | sort)
echo "PROCESSED=$N RCFAIL=$F"
