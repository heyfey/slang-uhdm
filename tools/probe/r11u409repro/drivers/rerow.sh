#!/bin/bash
# rerow.sh <workdir of a kept row> <binary> <out.uhdm> : rerun the row's slang command with another binary, then uhdm-cmp vs golden
d=$1; B=$2; O=$3
cmd=$(sed -n 's/^slang: *//p' $d/cmds.txt | sed "s#^[^ ]*#$B#; s#-o [^ ]*#-o $O#")
rm -f $O; eval "$cmd" > $O.log 2>&1; echo "rc=$?"
timeout 900 /home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp $d/slpp_all/surelog.uhdm $O > $O.cmp 2>&1; wc -l < $O.cmp
