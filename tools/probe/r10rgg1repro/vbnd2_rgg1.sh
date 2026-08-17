#!/usr/bin/env bash
# vrgg1 boundary arms, PART 2 — the yos1 vgrid/grid (.v and .sv, in
# subdirectories) plus the r10rgg1 arms, which live in the worktree.
set -u
PAT=${1:?A}; PRIS=${2:?B}
VARM=/home/heyfey/git-repos/slang-uhdm/tools/probe/r10earl49repro/varm.sh
STAGE=/tmp/vrgg1_bnd2
rm -rf "$STAGE"; mkdir -p "$STAGE"
same=0; diffn=0; noout=0; n=0
for d in /home/heyfey/git-repos/slang-uhdm/tools/probe/r10yos1repro/vgrid \
         /home/heyfey/git-repos/slang-uhdm/tools/probe/r10yos1repro/grid \
         /tmp/wt_vrgg1/tools/probe/r10rgg1repro; do
  [ -d "$d" ] || { echo "  MISSING DIR $d"; continue; }
  c=0
  for f in "$d"/*.sv "$d"/*.v; do
    [ -e "$f" ] || continue
    c=$((c+1)); n=$((n+1))
    b=$(basename "$f"); b=${b%.*}
    SLANG_UHDM=$PAT  bash "$VARM" "$f" "$STAGE/${b}_A" >/dev/null 2>&1
    SLANG_UHDM=$PRIS bash "$VARM" "$f" "$STAGE/${b}_B" >/dev/null 2>&1
    A=$STAGE/${b}_A/o.dump; B=$STAGE/${b}_B/o.dump
    if [ ! -s "$A" ] || [ ! -s "$B" ]; then
      echo "  $(basename $d)/$b  NO_OUTPUT"; noout=$((noout+1)); continue
    fi
    if diff <(sed "s#${b}_A#WD#g" "$A") <(sed "s#${b}_B#WD#g" "$B") >/dev/null; then
      same=$((same+1))
    else
      echo "  $(basename $d)/$b  *** o.dump DIFFERS ***"; diffn=$((diffn+1))
      diff <(sed "s#${b}_A#WD#g" "$A") <(sed "s#${b}_B#WD#g" "$B") | head -24
    fi
  done
  echo "  [$(basename $d)] arms=$c"
done
echo "BOUNDARY ARMS PART2: total=$n identical=$same differing=$diffn no_output=$noout"
