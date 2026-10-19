#!/bin/bash
# ddiff.sh <case> <tagA> [tagB]: dump diff golden vs ours(tagA) (and tagA vs tagB)
c=$1; D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
h=$(md5sum /tmp/v11u408_cases/$c/dut.sv | cut -c1-12)
g=/tmp/v11u408_gold/$h/slpp_all/surelog.uhdm
o=/tmp/v11u408_out/$c
$D $g 2>/dev/null | sed 's#/tmp/v11u408_[a-z]*/[^ ]*dut.sv#dut.sv#g; s#/tmp/v11u408_cases/[^ ]*dut.sv#dut.sv#g' > $o/gold.dump
for t in $2 $3; do $D $o/$t/ours.uhdm 2>/dev/null | sed 's#/tmp/v11u408_cases/[^ ]*dut.sv#dut.sv#g' > $o/$t.dump; done
