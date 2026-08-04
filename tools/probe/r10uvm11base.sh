#!/bin/bash
# r10uvm11base.sh — re-emit SeqDriver with the BASELINE (HEAD) binary built in
# /tmp/r10uvm11_base, so pass-11 census deltas can be attributed honestly.
set -u
cd ~/git-repos/Surelog/third_party/tests/SeqDriver || exit 1
/tmp/r10uvm11_base/build/slang-uhdm \
  +incdir+.+/home/heyfey/git-repos/Surelog/third_party/UVM/uvm-1.2/src/ \
  /home/heyfey/git-repos/Surelog/third_party/UVM/uvm-1.2/src/uvm_pkg.sv \
  design.sv testbench.sv --single-unit -o /tmp/r10uvm11_baseSeq.uhdm 2>/dev/null
/tmp/r10uvm11_e /tmp/r10uvm11_baseSeq.uhdm > /tmp/r10uvm11_eb.txt 2>/dev/null
echo "baseline elements=$(wc -l < /tmp/r10uvm11_eb.txt)"
awk -F'|' '{split($1,a,"/"); n=a[2]+0; if ($2=="method_func_call" && substr(a[1],2)+0==n-1) c++} END{print "baseline mfc-tail:",c+0}' /tmp/r10uvm11_eb.txt
awk -F'|' '{split($1,a,"/"); n=a[2]+0; if (n>=3) c++} END{print "baseline elems in >=3-elem hps:",c+0}' /tmp/r10uvm11_eb.txt
