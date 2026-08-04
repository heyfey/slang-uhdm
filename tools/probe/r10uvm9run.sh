#!/bin/bash
# r10uvm9run: build golden+ours for a purpose-built repro dir, both views.
#   r10uvm9run.sh <reprodir> <tag>
# Produces /tmp/r10uvm9_<tag>_{gd,sd,ge,se}.uhdm
#   gd/sd = def view  (-parse, no elab)     ge/se = elab view (-elabuhdm)
set -u
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_e4a1375e-b25-1
SU=/home/heyfey/git-repos/Surelog/build/bin/surelog
[ -x "$SU" ] || SU=/home/heyfey/git-repos/sv-tests/third_party/tools/Surelog/build/bin/surelog
SL=$W/build/slang-uhdm
D=$1; T=$2
O=/tmp/r10uvm9_$T
rm -rf $O; mkdir -p $O/gd $O/ge
(cd $D && $SU -parse -nobuiltin -nocache -sv -mt 0 -mp 0 -o $O/gd dut.sv >$O/gd.log 2>&1)
(cd $D && $SU -parse -nobuiltin -nocache -sv -elabuhdm -mt 0 -mp 0 -o $O/ge dut.sv >$O/ge.log 2>&1)
cp $(ls $O/gd/slpp_all/*.uhdm $O/gd/slpp_unit/*.uhdm 2>/dev/null | head -1) ${O}_gd.uhdm 2>/dev/null
cp $(ls $O/ge/slpp_all/*.uhdm $O/ge/slpp_unit/*.uhdm 2>/dev/null | head -1) ${O}_ge.uhdm 2>/dev/null
(cd $D && $SL --nobuiltin -o ${O}_sd.uhdm dut.sv >$O/sd.log 2>&1)
(cd $D && $SL --nobuiltin --elabuhdm -o ${O}_se.uhdm dut.sv >$O/se.log 2>&1)
ls -la ${O}_*.uhdm
