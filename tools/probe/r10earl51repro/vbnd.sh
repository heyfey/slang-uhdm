#!/usr/bin/env bash
# r10earl50 VERIFIER boundary-arm re-run.  Same contract as bndarms50.sh but it
# reads the arm sources OUT of the main tree (read-only) and stages them in the
# verifier's own /tmp scratch, so it does not depend on any particular worktree
# path being present.  A byte-identical o.dump is the strongest available
# statement that a boundary law is untouched.
#   usage: vbnd.sh <binA> <binB> <tag>
set -u
A=${1:?binA}; B=${2:?binB}; TAG=${3:?tag}
ROOT=/home/heyfey/git-repos/slang-uhdm/tools/probe
STAGE=/tmp/v49_bnd/$TAG
VARM=/tmp/v49_arms/varm.sh
rm -rf "$STAGE"; mkdir -p "$STAGE"
same=0; diffn=0; noout=0
for d in r10earl38repro r10earl45repro r10earl46repro r10earl47repro r10earl48repro; do
  [ -d "$ROOT/$d" ] || { echo "  MISSING DIR $d"; continue; }
  for f in "$ROOT/$d"/*.sv; do
    [ -e "$f" ] || continue
    b=$(basename "$f" .sv)
    cp "$f" "$STAGE/$b.sv"
    SLANG_UHDM=$A "$VARM" "$STAGE/$b.sv" "$STAGE/${b}_A" >/dev/null 2>&1
    SLANG_UHDM=$B "$VARM" "$STAGE/$b.sv" "$STAGE/${b}_B" >/dev/null 2>&1
    P=$STAGE/${b}_A/o.dump; Q=$STAGE/${b}_B/o.dump
    if [ ! -s "$P" ] || [ ! -s "$Q" ]; then echo "  $d/$b  NO_OUTPUT"; noout=$((noout+1)); continue; fi
    # the workdir path is baked into builtin.sv's location line -> normalise it
    if diff <(sed "s#${b}_A#WD#g" "$P") <(sed "s#${b}_B#WD#g" "$Q") >/dev/null; then
      same=$((same+1))
    else
      echo "  $d/$b  *** o.dump DIFFERS ***"; diffn=$((diffn+1))
      diff <(sed "s#${b}_A#WD#g" "$P") <(sed "s#${b}_B#WD#g" "$Q") | head -20
    fi
  done
done
echo "BOUNDARY ARMS [$TAG]: identical=$same differing=$diffn no_output=$noout"
