#!/bin/bash
# run law binary with env over dirs; compare bytes to pristine grid outputs
env_=$1; tag=$2; shift 2
for root in "$@"; do
  for c in $(find $root -name dut.sv | sort); do
    d=$(dirname $c); rel=${d#$root/}; name=${rel//\//__}
    out=/tmp/v11u133_s$tag; mkdir -p $out
    o=$out/$name.uhdm; rm -f $o
    (cd $d && env $env_ /tmp/v11u133_bin/law0 dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1)
    echo "$root $name"
  done
done
