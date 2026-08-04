#!/bin/bash
# r10bpfam: purpose-built golden.  Usage: r10bpfamgold.sh <dir> [extra surelog args]
D=$1; shift
cd "$D" || exit 1
rm -rf slpp_all
~/git-repos/Surelog/build/bin/surelog -parse -mt 0 -mp 0 "$@" t.sv > sl.log 2>&1
echo "exit=$?"
~/git-repos/UHDM/build/bin/uhdm-dump slpp_all/surelog.uhdm > g.txt 2>&1
wc -l g.txt
