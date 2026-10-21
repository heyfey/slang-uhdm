#!/bin/bash
# show.sh <casedir> <binary> [N]: run case.sh then print uhdm-cmp head (N lines) and the dump diff
c=$(readlink -f $1); B=$2; N=${3:-40}
bash /tmp/wt_v11u423/tools/probe/v11u423repro/drivers/case.sh $c $B
h=$(cat $c/dut.sv $c/TOP 2>/dev/null | md5sum | cut -c1-16); G=/tmp/v11u423_gold/$h
tag=$(echo "$c $B " | md5sum | cut -c1-12); O=/tmp/v11u423_scr/o_$tag.uhdm
/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp $G/golden.uhdm $O 2>&1 | head -$N
echo "---- dump diff"; diff <(sed 1d $G/golden.dump) <(sed 1d $O.dump) | head -$N
