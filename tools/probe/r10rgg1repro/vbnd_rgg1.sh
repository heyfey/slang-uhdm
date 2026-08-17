#!/usr/bin/env bash
# vrgg1 boundary-arm re-run — every .sv arm of the standing boundary laws, run
# with BOTH binaries, o.dump compared byte-for-byte after normalising the
# workdir path.  Dir list = earl49-54 fold grids + yos1 + the committed grids the
# standing ops rules name.
#   usage: vbnd_rgg1.sh <A_binary> <B_binary>
# GUARD: a missing/empty o.dump is NO_OUTPUT and is COUNTED; the arm count is
# printed so a silently-empty directory list is visible.
set -u
PAT=${1:?A}; PRIS=${2:?B}
ROOT=/home/heyfey/git-repos/slang-uhdm/tools/probe
VARM=$ROOT/r10earl49repro/varm.sh
STAGE=/tmp/vrgg1_bnd
rm -rf "$STAGE"; mkdir -p "$STAGE"
same=0; diffn=0; noout=0; n=0
for d in r10earl38repro r10earl45repro r10earl46repro r10earl47repro \
         r10earl48repro r10earl49repro r10earl50repro r10earl51repro \
         r10earl52repro r10earl53repro r10yos1repro r10rgg1repro; do
  [ -d "$ROOT/$d" ] || { echo "  MISSING DIR $d"; continue; }
  c=0
  for f in "$ROOT/$d"/*.sv; do
    [ -e "$f" ] || continue
    c=$((c+1)); n=$((n+1))
    b=$(basename "$f" .sv)
    SLANG_UHDM=$PAT  bash "$VARM" "$f" "$STAGE/${b}_A" >/dev/null 2>&1
    SLANG_UHDM=$PRIS bash "$VARM" "$f" "$STAGE/${b}_B" >/dev/null 2>&1
    A=$STAGE/${b}_A/o.dump; B=$STAGE/${b}_B/o.dump
    if [ ! -s "$A" ] || [ ! -s "$B" ]; then
      echo "  $d/$b  NO_OUTPUT"; noout=$((noout+1)); continue
    fi
    if diff <(sed "s#${b}_A#WD#g" "$A") <(sed "s#${b}_B#WD#g" "$B") >/dev/null; then
      same=$((same+1))
    else
      echo "  $d/$b  *** o.dump DIFFERS ***"; diffn=$((diffn+1))
      diff <(sed "s#${b}_A#WD#g" "$A") <(sed "s#${b}_B#WD#g" "$B") | head -24
    fi
  done
  echo "  [$d] arms=$c"
done
echo "BOUNDARY ARMS: total=$n identical=$same differing=$diffn no_output=$noout"
