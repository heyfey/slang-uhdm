#!/usr/bin/env bash
# vbuvm15 VERIFIER sweep driver -- MY OWN worktree, MY OWN out/workdir, one at a
# time, --jobs 2, GOLDEN_DEFER left UNSET and echoed, SLANG_UHDM exported
# EXPLICITLY, and every workdir cmds.txt re-read to prove which binary ran.
set -u
B=${1:?binary}; C=${2:?corpus}; O=${3:?out csv}; W=${4:?workdir}
[ -x "$B" ] || { echo "FATAL: no binary $B"; exit 3; }
cd "${REPO:-/tmp/wt_vbuvm15}" || exit 3
echo "== $(date +%T) sweep $C with $B -> $O (GOLDEN_DEFER=[${GOLDEN_DEFER:-UNSET}])"
SLANG_UHDM=$B timeout 43200 python3 scripts/verify_golden.py \
    --corpus "$C" --mode both --jobs 2 --out "$O" --workdir "$W" 2>&1 | tail -12
ncmd=$(ls "$W"/*/*/cmds.txt 2>/dev/null | wc -l)
[ "$ncmd" -gt 0 ] || { echo "FATAL: workdir $W has NO cmds.txt"; exit 5; }
echo "   cmds.txt files: $ncmd"
bad=$(grep -rh '^slang:' "$W"/*/*/cmds.txt 2>/dev/null | awk '{print $2}' | sort -u | grep -vFx "$B" | head -3)
[ -n "$bad" ] && { echo "FATAL: workdir $W names OTHER binaries: $bad"; exit 4; }
echo "   cmds.txt binary VERIFIED: $B"
echo "SWEEP DONE $C $B $(date +%T)"
