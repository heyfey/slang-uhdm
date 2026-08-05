#!/bin/bash
# r10uvm17m.sh [binary] [outdir] — re-emit the UVM-4 with `binary` using the
# SAME argv the harness records in its workdir cmds.txt, then print the
# r10uvm7b body-residue total per test.  Goldens come from a sweep workdir
# (R10W, default /tmp/r10uvm16_u4w); the golden cache is content-addressed so
# the cache paths inside cmds.txt are stable.
set -u
W=${R10WT:-/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_8e8c1173-cfe-1}
SU=${1:-$W/build/slang-uhdm}
OUT=${2:-/tmp/r10uvm17_m}
B=${R10B:-/tmp/r10uvm17_b}
SW=${R10W:-/tmp/r10uvm16_u4w}
mkdir -p "$OUT"
TOT=0
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  D=$(ls -d $SW/default/$T-* 2>/dev/null | head -1)
  [ -n "$D" ] || { echo "$T: no workdir"; continue; }
  G=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' "$D/cmds.txt" | head -1)/golden.uhdm
  ARGS=$(sed -n 's/^slang:   //p' "$D/cmds.txt" | cut -d' ' -f2- |
         sed "s#-o [^ ]*#-o $OUT/$T.uhdm#")
  case $T in
    BuildUVMPkg) TD=/home/heyfey/git-repos/Surelog/third_party/tests/BuildUVMPkg;;
    *)           TD=/home/heyfey/git-repos/Surelog/third_party/tests/$T;;
  esac
  ( cd "$TD" && eval "$SU $ARGS" >/dev/null 2>&1 )
  N=$($B "$G" "$OUT/$T.uhdm" part 2>/dev/null | awk '{s+=$1} END{print s+0}')
  echo "$T body-residue $N"
  TOT=$((TOT+N))
done
echo "TOTAL $TOT"
