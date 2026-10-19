#!/bin/bash
# ux.sh <dir> [bin]: sv-tests UVM recipe on uvm_pkg.sv + <dir>/dut.sv
. /tmp/r11u403_scr/env.sh
d=$(readlink -f $1); B=${2:-/tmp/r11u403_pristine.bin}
cd $d; rm -rf sl; mkdir sl
[ -s golden.uhdm ] && [ golden.uhdm -nt dut.sv ] || { timeout 900 $SURELOG -nopython -parse -nonote -noinfo -nowarning -I$UVM/src -I$d $UVM/src/uvm_pkg.sv $d/dut.sv -noprecompiledcache -mt 0 -mp 0 -o $d/sl > sl.log 2>&1; cp sl/slpp_all/surelog.uhdm golden.uhdm; }
rm -f ours.uhdm; timeout 900 $B -I$UVM/src -I$d $UVM/src/uvm_pkg.sv $d/dut.sv --single-unit -o $d/ours.uhdm > ours.log 2>&1; echo "rc=$?"
$UHDM_CMP golden.uhdm ours.uhdm 2>&1 | head -4
