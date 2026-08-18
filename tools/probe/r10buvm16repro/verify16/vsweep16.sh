#!/usr/bin/env bash
# r10vbuvm16 (VERIFIER) sweep driver.  NO hard-coded pass paths: the repo root
# comes in as $REPO.  usage: vsweep16.sh <binary> <corpus> <outcsv> <workdir>
set -u
B=${1:?binary}; C=${2:?corpus}; O=${3:?out csv}; W=${4:?workdir}
: "${REPO:?REPO=<worktree root>}"
[ -x "$B" ] || { echo "FATAL: no binary $B"; exit 3; }
cd "$REPO" || exit 3
echo "== $(date +%T) sweep $C with $B -> $O  (GOLDEN_DEFER=[${GOLDEN_DEFER:-UNSET}])"
SLANG_UHDM=$B timeout 43200 python3 scripts/verify_golden.py \
    --corpus "$C" --mode both --jobs 2 --out "$O" --workdir "$W" 2>&1 | tail -14
ncmd=$(ls "$W"/*/*/cmds.txt 2>/dev/null | wc -l)
[ "$ncmd" -gt 0 ] || { echo "FATAL: workdir $W has NO cmds.txt"; exit 5; }
echo "   cmds.txt files: $ncmd"
bad=$(grep -rh '^slang:' "$W"/*/*/cmds.txt 2>/dev/null | awk '{print $2}' | sort -u | grep -vFx "$B" | head -3)
if [ -n "$bad" ]; then echo "FATAL: workdir $W names OTHER binaries: $bad"; exit 4; fi
echo "   cmds.txt binary VERIFIED: $B"
echo "SWEEP DONE $C $B $(date +%T)"
