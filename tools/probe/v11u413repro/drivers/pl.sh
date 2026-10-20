#!/bin/bash
# v11u413 pl.sh <case rel> [binA binB]: dump diff A vs B
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
c=/tmp/wt_v11u413/tools/probe/v11u413repro/cases/$1; A=${2:-pristine}; B=${3:-law}
for b in $A $B; do rm -f /tmp/v11u413_scr/x_$b.uhdm; (cd $c && /tmp/v11u413_bin/$b dut.sv --single-unit --nobuiltin -o /tmp/v11u413_scr/x_$b.uhdm >/dev/null 2>&1); $D /tmp/v11u413_scr/x_$b.uhdm 2>/dev/null | sed 's/, id:[0-9]*//; s/ \[[0-9]*\]//' | grep -v 'vpiFile\|Restored design' > /tmp/v11u413_scr/x_$b.dump; done
diff /tmp/v11u413_scr/x_$A.dump /tmp/v11u413_scr/x_$B.dump
