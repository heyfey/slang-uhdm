#!/bin/bash
# ds <casedir> <P|L|M>: downstream verdict of one case
source $(dirname $0)/env.sh
c=$1; t=$2
case $t in P) export SLANG_UHDM=/tmp/v11u174_bin/pris;; L) export SLANG_UHDM=/tmp/v11u174_bin/law;; M) export SLANG_UHDM=/tmp/v11u174_bin/law2;; esac
n=$(echo $c | sed 's#.*/cases/##; s#/#_#g')
cd /tmp/wt_v11u174 && python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$n', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '/tmp/v11u174_dsw$t', 300); print('$t', '$n', r)"
