#!/bin/bash
# r10rggen5dbg: run slang-uhdm directly on the Rggen sources with R10RGGEN5_DBG
# set, capturing stderr diagnostics to /tmp/r10rggen5_dbg.txt.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_c688bbce-626-1
cd $HOME/git-repos/Surelog/third_party/tests/rggen
R10RGGEN5_DBG=1 $W/build/slang-uhdm -DSYNTHESIS=1 -Itests/generated/rggen \
  rggen-sv-rtl/rggen_rtl_pkg.sv rggen-sv-rtl/rggen_or_reducer.sv \
  rggen-sv-rtl/rggen_mux.sv rggen-sv-rtl/rggen_bit_field_if.sv \
  rggen-sv-rtl/rggen_bit_field.sv rggen-sv-rtl/rggen_bit_field_w01trg.sv \
  rggen-sv-rtl/rggen_register_if.sv rggen-sv-rtl/rggen_address_decoder.sv \
  rggen-sv-rtl/rggen_register_common.sv rggen-sv-rtl/rggen_default_register.sv \
  rggen-sv-rtl/rggen_external_register.sv rggen-sv-rtl/rggen_indirect_register.sv \
  rggen-sv-rtl/rggen_bus_if.sv rggen-sv-rtl/rggen_adapter_common.sv \
  rggen-sv-rtl/rggen_apb_if.sv rggen-sv-rtl/rggen_apb_adapter.sv \
  rggen-sv-rtl/rggen_apb_bridge.sv rggen-sample/block_0.sv rggen-sample/block_1.sv \
  tests/generated/rggen/rggen.sv --single-unit -o /tmp/r10rggen5_dbg.uhdm \
  2> /tmp/r10rggen5_dbg.txt
echo "rc=$? stderr-lines=$(wc -l < /tmp/r10rggen5_dbg.txt)"
sort /tmp/r10rggen5_dbg.txt | uniq -c | sort -rn | head -${1:-25}
