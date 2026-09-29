#!/bin/bash
# pin1.sh <casedir> <record index in ours> [EL]: the mint site of one of OUR objects in a case, by gdb on the -g1 build
# ($B/law.v2.g1 or $G1): the record's UhdmId (strictcmp_x --dump-ids) -> its creation rank among its type (objrank)
# -> a breakpoint on UHDM::Serializer::Make<type> ignoring rank-1 hits -> the backtrace. Cases only (never a corpus
# test): a path holding a fenced name is refused.
[ -n "$FENCED" ] && [ -n "$S" ] || { echo "pin1.sh: source drivers/env.sh" >&2; exit 2; }
c=$(realpath $1); j=$2; el=${3:-0}; G1=${G1:-$B/law.v2.g1}
for n in $FENCED; do echo "$c" | grep -qw "$n" && { echo "pin1.sh: fenced path refused" >&2; exit 2; }; done
rel=$(echo $c | sed "s#.*/r11u218dec/cases/##; s#.*/tests/probe/#probe/#; s#.*/tools/probe/#tp/#")
ek=""; ox=""; [ "$el" = 1 ] && { ek="_el"; ox="--elabuhdm"; }
w=$S/g/$rel$ek; g=$(ls $w/gold_*/golden.uhdm | head -1); o=$w/pin.uhdm; rm -f $o
SRC=dut.sv; [ -f $c/args ] && SRC=$(cat $c/args)
(cd $c && $G1 $SRC --single-unit --nobuiltin $ox -o $o > /dev/null 2>&1)
$B/strictcmp_x --max 0 --dump-ids --dump-a $w/pin.a --dump-b $w/pin.b $g $o > /dev/null 2>&1
rec=$(sed -n "$((j+1))p" $w/pin.b); t=$(echo "$rec" | cut -f2); id=$(echo "$rec" | cut -f15 | awk -F'\x1f' '{print $5}')
rank=$($B/objrank $o | awk -F'\t' -v T=$t -v I=$id '$1==T && $3==I {print $2}')
echo "record #$j type=$t id=$id rank=$rank: $(echo "$rec" | cut -f1-10 | tr '\t' ' ')"
M=Make$(echo ${t:0:1} | tr a-z A-Z)${t:1}
(cd $c && gdb -q -batch -ex "set pagination off" -ex "break UHDM::Serializer::$M" -ex "ignore 1 $((rank-1))" -ex "run" -ex "bt 14" --args $G1 $SRC --single-unit --nobuiltin $ox -o $w/pin2.uhdm 2>&1) | grep -E '^#[0-9]+' | sed 's/ (.*) at / at /; s/0x[0-9a-f]* in //' | cut -c1-200
