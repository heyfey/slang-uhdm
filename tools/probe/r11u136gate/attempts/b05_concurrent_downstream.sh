#!/bin/bash
# B5: two downstream sweeps of the same tests at once (two agents, one
# machine): the Yosys run dir is /tmp/u2rds-<sha1(name/lane/workdir/pid)[:12]>,
# fixed length, distinct per process. Expected: both runs IDENTICAL, and their
# RTLIL/netlist files byte-identical to each other.
# Usage: <repo> <workdir-prefix>   (the two workdirs have the same length)
set -u; R=$1; P=$2; F='^(adff|aes_kexp128|add_sub_bind_if|allconst_attr)$'
rm -rf ${P}A ${P}B
echo "+ two concurrent: tests/sweep.sh --corpus downstream --filter '$F' --workdir ${P}A | ${P}B"
$R/tests/sweep.sh --jobs 3 --corpus downstream --filter "$F" --workdir ${P}A > ${P}A.log 2>&1 & a=$!
$R/tests/sweep.sh --jobs 3 --corpus downstream --filter "$F" --workdir ${P}B > ${P}B.log 2>&1 & b=$!
wait $a; ra=$?; wait $b; rb=$?
grep downstream: ${P}A.log ${P}B.log; echo "rc A=$ra B=$rb"
n=0; d=0; for f in $(cd ${P}A/downstream && find . -name '*.il' -o -name '*_synth.v' | sort); do n=$((n+1)); cmp -s ${P}A/downstream/$f ${P}B/downstream/$f || { d=$((d+1)); echo "DIFFERS $f"; }; done
echo "files compared=$n differing=$d"
cmp <(cut -d, -f1-7 ${P}A/downstream.csv) <(cut -d, -f1-7 ${P}B/downstream.csv) && echo "csvs equal"
