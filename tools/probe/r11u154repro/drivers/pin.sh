#!/bin/bash
# pin.sh <case dir> <record index (0-based, B side)> [bin_g1] [frames]: the mint site of OUR object at that strict record.
# Runs the -g1 exporter under gdb (breakpoint on Serializer::Make<type>, ignore rank-1) in the case dir.
source /tmp/r11u154_env.sh
d=$(cd "$1" && pwd); n=$2; G1=${3:-/tmp/r11u154_bin/pris_g1.bin}; F=${4:-14}
g=$(cat /tmp/r11u154_s/gpath/$(echo $d | md5sum | cut -c1-12))
T=$(mktemp -d /tmp/r11u154_pin.XXXX)
(cd $d && $G1 dut.sv --single-unit --nobuiltin -o $T/o.uhdm >/dev/null 2>&1)
/tmp/r11u154_bin/strictcmp_x --max 1 --dump-ids --dump-a $T/a --dump-b $T/b $g $T/o.uhdm >/dev/null 2>&1
line=$(sed -n "$((n+1))p" $T/b); id=${line##*$'\x1f'}; typ=$(echo "$line" | cut -f2)
rank=$(/tmp/r11u154_bin/objrank $T/o.uhdm | awk -F'\t' -v t=$typ -v i=$id '$1==t && $3==i{print $2}')
echo "record $n: $typ id=$id rank=$rank :: $(echo "$line" | cut -f1-12 | tr '\t' ' ')"
T2=${typ^}
(cd $d && gdb -q -batch -ex "set pagination off" -ex "break UHDM::Serializer::Make${T2}" -ex "ignore 1 $((rank-1))" -ex run -ex "bt $F" --args $G1 dut.sv --single-unit --nobuiltin -o $T/p.uhdm 2>&1) | grep -E '^#' | sed 's/ (.*) at / at /' | cut -c1-200
rm -rf $T
