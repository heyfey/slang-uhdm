#!/bin/bash
# usage: run.sh <binary> <out.uhdm>
B=$1; O=$2; rm -f "$O"
U=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/UVM/1800.2-2017-1.0/src
T=/home/heyfey/git-repos/sv-tests/third_party/tests/uvm-examples/uvm_param_vif_config_db
"$B" -I$U -I$T/sfr_agent -I$T/sfr_test_pkg $U/uvm_pkg.sv $T/./sfr_agent/sfr_agent_pkg.sv $T/./sfr_agent/sfr_master_bfm.sv $T/./sfr_agent/sfr_monitor_bfm.sv $T/./tb/tb_params_pkg.sv $T/./sfr_test_pkg/sfr_test_pkg.sv $T/./tb/hdl_top.sv $T/./tb/hvl_top.sv $T/./rtl/sfr_dut.sv --single-unit -o "$O"
echo rc=$?
