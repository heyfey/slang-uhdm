#!/bin/bash
# v11u287 golden_keepfold.sh <case dir>: Surelog's database (the v1.87 pin, check_probe's arguments) and the pristine
# and law binaries' on one fresh case; prints the count of each Rhs kind under every vpiRhs (a kept call shows one
# constant fewer than a fold). Fresh cases only: refuses a path naming a fenced test.
H=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$H/../../../.." && pwd)
. $REPO/tools/probe/r11u287repro/drivers/env.sh || exit 2
for n in $FENCED; do echo "$1" | grep -qw "$n" && { echo refused; exit 2; }; done
c=$(realpath $1); w=$S/kf/$(basename $c); rm -rf $w; mkdir -p $w
(cd $c && timeout 120 $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $w/s > /dev/null 2>&1)
g=$(find $w/s -name '*.uhdm' | head -1)
cls(){ [ -s "$1" ] || { echo NONE; return; }; $UHDM_DUMP $1 2>/dev/null | grep -A1 'vpiRhs:' | grep -oE '\\_(func_call|constant|operation|ref_obj)' | sort | uniq -c | tr -s ' ' | tr '\n' ' '; }
(cd $c && $B/pris dut.sv --single-unit --nobuiltin -o $w/p.uhdm >/dev/null 2>&1); (cd $c && $B/law dut.sv --single-unit --nobuiltin -o $w/l.uhdm >/dev/null 2>&1)
echo "$(basename $c) G[$(cls $g)] P[$(cls $w/p.uhdm)] L[$(cls $w/l.uhdm)]"
