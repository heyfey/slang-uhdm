#!/bin/bash
# usage: run19.sh <file.sv> [extra slang args...]
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_8e1be37e-85d-1
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
F=$1; shift
case "$F" in /*) ;; *) F=$W/tools/probe/r10earl_repro/$F ;; esac
B=$(basename "$F" .sv)
D=/tmp/r10earl23_rep/out_$B
rm -rf "$D"; mkdir -p "$D"
mkdir -p /tmp/r10earl23_rep
cd /tmp/r10earl23_rep || exit 1
$SL -parse -nocache -mt 0 -mp 0 -d uhdm "$F" -o "$D/sl" > "$D/sl.log" 2>&1
echo "surelog rc=$?"
$W/build/slang-uhdm "$F" "$@" -o "$D/ours.uhdm" > "$D/ours.log" 2>&1
echo "slang rc=$?"
G=$(ls "$D"/sl/slpp_all/*.uhdm 2>/dev/null | head -1)
echo "golden=$G"
/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp "$G" "$D/ours.uhdm" 2>&1 | head -40
