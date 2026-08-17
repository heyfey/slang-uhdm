#!/usr/bin/env bash
# v51 VERIFIER boundary-arm re-run — EVERY .sv arm of the standing boundary laws
# run with BOTH binaries, o.dumps compared byte-for-byte after normalising the
# workdir path.  Directory list includes r10earl49repro and r10earl50repro, the
# two the standing ops rules name explicitly.
#   usage: vbnd51.sh <patched> <pristine>
# GUARDS: a missing/empty o.dump is NO_OUTPUT and is COUNTED (a driver that
# reaches nothing must never read as perfection); the arm count is printed so a
# silently-empty directory list is visible.
set -u
PAT=${1:?patched}; PRIS=${2:?pristine}
ROOT=/home/heyfey/git-repos/slang-uhdm/tools/probe
HERE=$(cd "$(dirname "$0")" && pwd)
VARM=${VARM:-$HERE/varm.sh}
STAGE=/tmp/v51_bnd
rm -rf "$STAGE"; mkdir -p "$STAGE"
same=0; diffn=0; noout=0; n=0
for d in r10earl38repro r10earl45repro r10earl46repro r10earl47repro \
         r10earl48repro r10earl49repro r10earl50repro; do
  [ -d "$ROOT/$d" ] || { echo "  MISSING DIR $d"; continue; }
  c=0
  for f in "$ROOT/$d"/*.sv; do
    [ -e "$f" ] || continue
    c=$((c+1)); n=$((n+1))
    b=$(basename "$f" .sv)
    cp "$f" "$STAGE/$b.sv"
    SLANG_UHDM=$PAT  "$VARM" "$STAGE/$b.sv" "$STAGE/${b}_A" >/dev/null 2>&1
    SLANG_UHDM=$PRIS "$VARM" "$STAGE/$b.sv" "$STAGE/${b}_B" >/dev/null 2>&1
    A=$STAGE/${b}_A/o.dump; B=$STAGE/${b}_B/o.dump
    if [ ! -s "$A" ] || [ ! -s "$B" ]; then
      echo "  $d/$b  NO_OUTPUT"; noout=$((noout+1)); continue
    fi
    if diff <(sed "s#${b}_A#WD#g" "$A") <(sed "s#${b}_B#WD#g" "$B") >/dev/null; then
      same=$((same+1))
    else
      echo "  $d/$b  *** o.dump DIFFERS ***"; diffn=$((diffn+1))
      diff <(sed "s#${b}_A#WD#g" "$A") <(sed "s#${b}_B#WD#g" "$B") | head -30
    fi
  done
  echo "  [$d] arms=$c"
done
echo "BOUNDARY ARMS: total=$n identical=$same differing=$diffn no_output=$noout"
