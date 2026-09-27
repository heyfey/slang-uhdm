#!/bin/bash
# ds.sh <casedir> <binary> <tag>: downstream verdict of one case
source $(dirname "${BASH_SOURCE[0]}")/env.sh
c=$(realpath $1); if echo "$c" | grep -qP "$FENCED_RE"; then echo FENCE; exit 4; fi
export SLANG_UHDM=$2
name=$(echo $c | sed 's#/tmp/v11u181_cases/##; s#/#_#g')
wr=/tmp/v11u181_ds/$3; mkdir -p $wr
cd /tmp/wt_v11u181pris && python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; print(ds.one('$name', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$wr', 300))"
