#!/bin/bash
# r10uvm12m.sh [binary] [outdir] — re-emit the UVM-4 with `binary` (default:
# this worktree's) using the SAME argv the harness records in its workdir
# cmds.txt, then print the r10uvm7b body-residue total per test.  Goldens come
# from the pass-11 sweep workdir (the golden cache is content-addressed, so the
# paths are stable across passes).
set -u
SU=${1:-/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_d9ea24db-18b-1/build/slang-uhdm}
OUT=${2:-/tmp/r10uvm12_m}
mkdir -p "$OUT"
TOT=0
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  D=$(ls -d /tmp/r10uvm11_slw/default/$T-* 2>/dev/null | head -1)
  [ -n "$D" ] || { echo "$T: no workdir"; continue; }
  G=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' "$D/cmds.txt" | head -1)/golden.uhdm
  ARGS=$(sed -n 's/^slang:   //p' "$D/cmds.txt" | cut -d' ' -f2- |
         sed "s#-o [^ ]*#-o $OUT/$T.uhdm#")
  case $T in
    BuildUVMPkg) TD=/home/heyfey/git-repos/Surelog/third_party/tests/BuildUVMPkg;;
    *)           TD=/home/heyfey/git-repos/Surelog/third_party/tests/$T;;
  esac
  ( cd "$TD" && eval "$SU $ARGS" >/dev/null 2>&1 )
  N=$(/tmp/r10uvm12_b "$G" "$OUT/$T.uhdm" part 2>/dev/null | awk '{s+=$1} END{print s+0}')
  echo "$T body-residue $N"
  TOT=$((TOT+N))
done
echo "TOTAL $TOT"
