#!/bin/bash
# runpvc.sh <bin> <tag>: one direct export of sv-tests uvm_param_vif_config_db with the
# runner's recorded slang command line (cmds.txt of the master's control), then uhdm-cmp
# line count and the strict verdict against the cached golden.  Single process.
source /tmp/r11u479_env.sh || exit 1
B=$1; T=$2; [ -x "$B" ] || { echo "no binary $B"; exit 1; }
G=/home/heyfey/.cache/slang-uhdm-goldens/0445655ee703/50a224b0134d47ab3870/golden.uhdm
U=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/UVM/1800.2-2017-1.0/src
S=/home/heyfey/git-repos/sv-tests/third_party/tests/uvm-examples/uvm_param_vif_config_db
O=/tmp/r11u479_pvc/$T; mkdir -p $O; rm -f $O/slang.uhdm
"$B" -I$U -I$S/sfr_agent -I$S/sfr_test_pkg $U/uvm_pkg.sv $S/./sfr_agent/sfr_agent_pkg.sv $S/./sfr_agent/sfr_master_bfm.sv $S/./sfr_agent/sfr_monitor_bfm.sv $S/./tb/tb_params_pkg.sv $S/./sfr_test_pkg/sfr_test_pkg.sv $S/./tb/hdl_top.sv $S/./tb/hvl_top.sv $S/./rtl/sfr_dut.sv --single-unit -o $O/slang.uhdm > $O/slang.log 2>&1 </dev/null
echo "rc=$?"
$UHDM_CMP $G $O/slang.uhdm > $O/cmp.txt 2>&1; echo "cmp=$(wc -l < $O/cmp.txt)"
