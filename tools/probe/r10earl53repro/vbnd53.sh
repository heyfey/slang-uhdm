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
STAGE=/tmp/r10earl53_bnd
rm -rf "$STAGE"; mkdir -p "$STAGE"
same=0; diffn=0; noout=0; n=0; attrn=0
# r10earl53 FIX: the carried-forward list named `r10earl53repro`, a directory
# that exists only in THIS worktree, so the boundary run silently skipped the
# pass's OWN arms and skipped r10earl51/52's as well -- the two most recent
# landed laws, which the standing brief names explicitly (earl49-52).  The list
# now spans 38 and 45..52 from the MAIN tree and picks this pass's own arms up
# from $HERE, and a directory that resolves to nothing is reported, not skipped.
for d in r10earl38repro r10earl45repro r10earl46repro r10earl47repro \
         r10earl48repro r10earl49repro r10earl50repro r10earl51repro \
         r10earl52repro SELF; do
  if [ "$d" = SELF ]; then DIR=$HERE; else DIR=$ROOT/$d; fi
  [ -d "$DIR" ] || { echo "  MISSING DIR $d"; continue; }
  c=0
  for f in "$DIR"/*.sv; do
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
      # r10earl53: § connPathRootTs53 is a CORPUS-WIDE rule, so a boundary arm
      # that HAS a struct-member port connection is SUPPOSED to move.  "0
      # differing arms" is therefore the WRONG gate here and would have to be
      # bought by not running the rule.  The gate that means something is:
      # every differing arm's delta is the RULE'S SIGNATURE and loses nothing.
      # An arm whose delta attr53.py cannot explain is a REGRESSION and is
      # printed in full.
      if python3 "$HERE/attr53.py" "$B" "$A" > "$STAGE/${b}.attr" 2>&1; then
        echo "  $d/$b  moved, ATTRIBUTED: $(head -1 "$STAGE/${b}.attr")"
        attrn=$((attrn+1))
      else
        echo "  $d/$b  *** o.dump DIFFERS, UNEXPLAINED ***"; diffn=$((diffn+1))
        head -12 "$STAGE/${b}.attr"
        diff <(sed "s#${b}_A#WD#g" "$A") <(sed "s#${b}_B#WD#g" "$B") | head -30
      fi
    fi
  done
  echo "  [$d] arms=$c"
done
echo "BOUNDARY ARMS: total=$n identical=$same attributed=$attrn UNEXPLAINED=$diffn no_output=$noout"
