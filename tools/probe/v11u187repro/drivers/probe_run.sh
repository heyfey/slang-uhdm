#!/bin/bash
# probe_run.sh <binary> <outdir> [ENV=VAL...]: run a binary over every tests/probe case of the law worktree (check_probe's args)
source $(dirname "${BASH_SOURCE[0]}")/env.sh || exit 9
b=$1; od=$2; shift 2; mkdir -p $od
cd $V187/tests/probe && find . -name dut.sv | sed 's#^\./##; s#/dut.sv$##' | sort > $od/list.txt
export B=$b OD=$od V187; export EXTRA="$*"
xargs -P 3 -a $od/list.txt -I{} bash -c 'n=$(echo {} | sed "s#/#__#g"); rm -f $OD/$n.uhdm; (cd $V187/tests/probe/{} && env $EXTRA timeout 300 $B dut.sv --single-unit --nobuiltin -o $OD/$n.uhdm >/dev/null 2>&1 </dev/null); echo "$n $?" >> $OD/rc.txt'
