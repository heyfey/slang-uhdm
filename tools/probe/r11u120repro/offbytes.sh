#!/usr/bin/env bash
# offbytes.sh <law binary> <pristine binary> <dir>...: every dut.sv arm under the
# dirs, built by both binaries with the probe flags (and the law binary with
# R11U120_OFF=1, plus --filterprotected which must then be a no-op): prints
# SAME/DIFF per arm and the totals.  The whole-pass switch must restore
# pristine bytes on every arm.
set -u
L=$1; P=$2; shift 2
W=/tmp/r11u120_offbytes; rm -rf $W; mkdir -p $W
n=0; same=0; diff=0
while read -r a <&3; do
  n=$((n+1)); k=$(echo "$a" | md5sum | cut -c1-12)
  (cd "$a" && $P dut.sv --single-unit --nobuiltin -o $W/$k.p.uhdm >/dev/null 2>&1 </dev/null; echo $? > $W/$k.p.rc)
  (cd "$a" && R11U120_OFF=1 $L dut.sv --single-unit --nobuiltin --filterprotected -o $W/$k.l.uhdm >/dev/null 2>&1 </dev/null; echo $? > $W/$k.l.rc)
  if [ "$(cat $W/$k.p.rc)" = "$(cat $W/$k.l.rc)" ] && cmp -s $W/$k.p.uhdm $W/$k.l.uhdm; then same=$((same+1)); else diff=$((diff+1)); echo "DIFF $a rc=$(cat $W/$k.p.rc)/$(cat $W/$k.l.rc)"; fi
done 3< <(find "$@" -name dut.sv -printf '%h\n' | sort)
echo "ARMS=$n SAME=$same DIFF=$diff"
