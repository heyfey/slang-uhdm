#!/usr/bin/env bash
# v196 VERIFIER arm runner — measurement only; uhdm-cmp is the judge.
set -u
D=/tmp/v196_arms
R=/tmp/wt_v196/tools/probe/r10uvm196repro
export IMP=/tmp/v196_bin/ct196imp CEN=/tmp/v196_bin/ct196cen
A=/tmp/v196_frozen/pris.bin
B=/tmp/v196_frozen/pat.bin
run() { n=$1; shift; bash $R/grid196.sh "$n" "$A" "$B" /tmp/v196_wd/arms/$n "$@" > /tmp/v196_wd/arms/$n.out 2>&1; echo "ARM $n rc=$?"; }
mkdir -p /tmp/v196_wd/arms
run x1_inst    $D/v196_pkg.sv $D/v196_x1_inst.sv
run x2_spec    $D/v196_pkg.sv $D/v196_x2_spec.sv
run x3_hdr     $D/v196_pkg.sv $D/v196_x3_hdr.sv
run x4_after   $D/v196_pkg.sv $D/v196_x4_after.sv
run x5_iface   $D/v196_pkg.sv $D/v196_x5_iface.sv
run x6_twofile $D/v196_pkg.sv $D/v196_x6_a.sv $D/v196_x6_b.sv
run x7_inc     $D/v196_pkg.sv $D/v196_x7_inc.sv
run x8_macro   $D/v196_pkg.sv $D/v196_x8_macro.sv
run x9_dup     $D/v196_pkg.sv $D/v196_x9_dup.sv
run x10_defonly $D/v196_pkg.sv $D/v196_x10_defonly.sv
run x11_nested $D/v196_pkg.sv $D/v196_x11_nested.sv
echo ALL_ARMS_DONE
