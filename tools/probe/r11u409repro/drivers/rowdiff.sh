#!/bin/bash
# rowdiff.sh <workroot> <rel test path w/o .sv>
d=$1/$2; g=$(sed -n 's/.*cache hit \(.*\))/\1/p' $d/cmds.txt)/golden.uhdm; [ -f "$g" ] || g=$d/slpp_all/surelog.uhdm
$(dirname $0)/ddiff.sh $g $d/slang.uhdm
