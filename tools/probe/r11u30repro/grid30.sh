#!/usr/bin/env bash
# r11u30 — MEASUREMENT ONLY.  The whole golden grid for
# § insideOpenRangeMemberIsOneListOp30: every arm x both views, scored
# golden(LHS) / pristine / patched by the committed r10uvm99 three-way scorer
# (`tools/probe/r10uvm99repro/three99.sh` + `opcen99.py`), whose census key is
# the INSIDE/LISTOP operation's nearest named ancestor + span.
#   PAT=<bin> PRI=<bin> ./grid30.sh [arm.sv ...]
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
U99=$HERE/../r10uvm99repro
export PAT=${PAT:?} PRI=${PRI:?} ARMWD=${ARMWD:-/tmp/r11u30_armwd}
ARMS=("$@")
if [ ${#ARMS[@]} -eq 0 ]; then ARMS=($U99/g99_a*.sv $HERE/g30_b*.sv); fi
for a in "${ARMS[@]}"; do
  for v in def elab; do
    MODE=$v bash "$U99/three99.sh" "$a"
  done
done
