#!/usr/bin/env bash
# r10earl53 BOUNDARY ARM RE-RUN: every .sv arm of the standing boundary laws is
# run with BOTH binaries and their o.dump compared.  A byte-identical o.dump is
# the strongest available statement that the boundary law is untouched: it is
# not a cmp head, not a count, it is the whole database.
#
#   usage: bndarms51.sh <patched-bin> <pristine-bin>
#
# r10earl53 widens the directory list to the two the standing ops rules name
# explicitly — r10earl49repro (the b1/b2/c1/d1/e1/f1/g1/a1 + v1..v8 grid) and
# r10earl50repro (h1..h8 + w1..w5) — which the carried-forward script omitted.
set -u
PAT=${1:?patched}; PRIS=${2:?pristine}
ROOT=/home/heyfey/git-repos/slang-uhdm/tools/probe
HERE=$(cd "$(dirname "$0")" && pwd)
ARM=$HERE/arm51.sh
STAGE=/tmp/r10earl53_bnd
rm -rf "$STAGE"; mkdir -p "$STAGE"
same=0; diffn=0; noout=0
for d in r10earl38repro r10earl45repro r10earl46repro r10earl47repro \
         r10earl48repro r10earl49repro r10earl50repro; do
  [ -d "$ROOT/$d" ] || { echo "  MISSING DIR $d"; continue; }
  for f in "$ROOT/$d"/*.sv; do
    [ -e "$f" ] || continue
    b=$(basename "$f" .sv)
    cp "$f" "$HERE/$b.sv.bnd" 2>/dev/null || continue
    mv "$HERE/$b.sv.bnd" "$HERE/$b.sv"
    SLANG_UHDM=$PAT  "$ARM" "$b.sv" "$STAGE/${b}_pat"  >/dev/null 2>&1
    SLANG_UHDM=$PRIS "$ARM" "$b.sv" "$STAGE/${b}_pris" >/dev/null 2>&1
    # never delete an arm this pass OWNS
    case "$b" in i1_earl51|i2_earl51|i3_earl51|i4_earl51) ;; *) rm -f "$HERE/$b.sv";; esac
    A=$STAGE/${b}_pat/o.dump; B=$STAGE/${b}_pris/o.dump
    if [ ! -s "$A" ] || [ ! -s "$B" ]; then
      echo "  $d/$b  NO_OUTPUT"; noout=$((noout+1)); continue
    fi
    # the workdir path is baked into the dump's location lines -> normalise it
    if diff <(sed "s#${b}_pat#WD#g" "$A") <(sed "s#${b}_pris#WD#g" "$B") >/dev/null; then
      same=$((same+1))
    else
      echo "  $d/$b  *** o.dump DIFFERS ***"; diffn=$((diffn+1))
      diff <(sed "s#${b}_pat#WD#g" "$A") <(sed "s#${b}_pris#WD#g" "$B") | head -30
    fi
  done
done
echo "BOUNDARY ARMS: identical=$same differing=$diffn no_output=$noout"
