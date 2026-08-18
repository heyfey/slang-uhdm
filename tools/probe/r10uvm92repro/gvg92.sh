#!/usr/bin/env bash
# r10uvm92 — THE GOLDEN-vs-GOLDEN CENSUS, run FIRST and on GOLDEN ONLY.
#
# `ct92cen` transcribes BOTH of Surelog's closed dispatches --
# `CompileHelper::decompileHelper` (CompileHelper.cpp:2544) composed with
# `UHDM::ExprEval::prettyPrint` (ExprEval.cpp:949) -- and applies them to each
# path element of a golden database's OWN tree, then compares the result to the
# bracket text that database's hier_path NAME actually carries.  EXPM=Y means
# the decode reproduced golden byte for byte on that object.
#
# A single EXPM=N anywhere in the corpus REFUTES the decode.  Run it before
# writing any code, and again over the arms.
#   usage: gvg92.sh <workdir root>
set -u
WD=${1:?workdir root}
CEN=${CEN:-/tmp/r10uvm92_ct92cen}
tot=0; withop=0; y=0; n=0; bad=0
for d in "$WD"/default/*/ "$WD"/testflags/*/; do
  [ -d "$d" ] || continue
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" 2>/dev/null | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm || continue
  [ -f "$G" ] || continue
  tot=$((tot+1))
  line=$("$CEN" "$G" --op 2>&1 >/dev/null | tail -1)
  wo=$(printf '%s' "$line" | sed -n 's/.*with-op-index=\([0-9]*\).*/\1/p')
  yy=$(printf '%s' "$line" | sed -n 's/.*EXPM_Y=\([0-9]*\).*/\1/p')
  nn=$(printf '%s' "$line" | sed -n 's/.*EXPM_N=\([0-9]*\).*/\1/p')
  withop=$((withop + ${wo:-0})); y=$((y + ${yy:-0})); n=$((n + ${nn:-0}))
  if [ "${nn:-0}" -gt 0 ]; then
    bad=$((bad+1))
    echo "REFUTED ${d#$WD/} EXPM_N=$nn"
    "$CEN" "$G" --op 2>/dev/null | grep 'EXPM=N' | head -5
  fi
done
echo "-- goldens=$tot  op-index hier_paths=$withop  EXPM_Y=$y  EXPM_N=$n  refuting goldens=$bad"
