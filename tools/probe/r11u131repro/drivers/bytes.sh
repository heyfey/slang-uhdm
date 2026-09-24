#!/usr/bin/env bash
# bytes.sh <dir> <binA> <binB> [ENV=VAL for binB] : byte-compare the databases of
# every case (a dir holding dut.sv) under <dir> between two binaries.
# Prints one line per case that differs, then "SAME n / DIFF m".
set -u
root=$(realpath $1); A=$2; B=$3; envB=${4:-}
t=$(mktemp -d /tmp/r11u131_bytes.XXXXXX)
same=0; diff=0
while read -r c; do
  (cd $c && $A dut.sv --single-unit --nobuiltin -o $t/a.uhdm >/dev/null 2>&1)
  (cd $c && env $envB $B dut.sv --single-unit --nobuiltin -o $t/b.uhdm >/dev/null 2>&1)
  if cmp -s $t/a.uhdm $t/b.uhdm; then same=$((same+1)); else diff=$((diff+1)); echo "DIFF ${c#$root/}"; fi
  rm -f $t/a.uhdm $t/b.uhdm
done < <(find $root -name dut.sv -printf '%h\n' | sort)
rm -rf $t
echo "SAME $same / DIFF $diff"
