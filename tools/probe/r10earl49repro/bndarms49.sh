#!/usr/bin/env bash
# r10earl49 BOUNDARY ARM RE-RUN: every .sv arm of the four boundary laws is run
# with BOTH binaries and their o.dump compared.  A byte-identical o.dump is the
# strongest available statement that the boundary law is untouched: it is not a
# cmp head, not a count, it is the whole database.
set -u
PAT=${1:?patched}; PRIS=${2:?pristine}
ROOT=/home/heyfey/git-repos/slang-uhdm/tools/probe
ARM=/tmp/wt_r10earl49/tools/probe/r10earl49repro/arm49.sh
same=0; diffn=0
for d in r10earl38repro r10earl45repro r10earl46repro r10earl47repro r10earl48repro; do
  for f in "$ROOT/$d"/*.sv; do
    b=$(basename "$f" .sv)
    cp "$f" /tmp/wt_r10earl49/tools/probe/r10earl49repro/ 2>/dev/null || continue
    SLANG_UHDM=$PAT  "$ARM" "$b.sv" /tmp/r10earl49/bnd/${b}_pat  >/dev/null 2>&1
    SLANG_UHDM=$PRIS "$ARM" "$b.sv" /tmp/r10earl49/bnd/${b}_pris >/dev/null 2>&1
    rm -f /tmp/wt_r10earl49/tools/probe/r10earl49repro/"$b.sv"
    A=/tmp/r10earl49/bnd/${b}_pat/o.dump; B=/tmp/r10earl49/bnd/${b}_pris/o.dump
    if [ ! -s "$A" ] || [ ! -s "$B" ]; then echo "  $d/$b  NO_OUTPUT"; continue; fi
    # the workdir path is baked into builtin.sv's location line -> normalise it
    if diff <(sed "s#${b}_pat#WD#g" "$A") <(sed "s#${b}_pris#WD#g" "$B") >/dev/null; then
      echo "  $d/$b  o.dump IDENTICAL"; same=$((same+1))
    else
      echo "  $d/$b  *** o.dump DIFFERS ***"; diffn=$((diffn+1))
      diff <(sed "s#${b}_pat#WD#g" "$A") <(sed "s#${b}_pris#WD#g" "$B") | head -20
    fi
  done
done
echo "BOUNDARY ARMS: identical=$same differing=$diffn"
