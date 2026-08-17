#!/usr/bin/env bash
# r10buvm7 — one verify_golden sweep, run ONE AT A TIME at --jobs 2.
#
#   usage: sweeps.sh <binary> <corpus> <mode> <outcsv> <workdir>
#
# GUARDS, each an ops trap this campaign has paid for:
#   * verify_golden.py SILENTLY DEFAULTS SLANG_UHDM to the MAIN-TREE binary, so
#     it is exported here AND re-read out of every workdir's own cmds.txt
#     afterwards; a sweep whose cmds.txt names a different binary is FATAL.
#   * GOLDEN_DEFER is left UNSET and echoed, so the five memory giants read
#     DEFERRED in both modes exactly as the committed baselines do.
#   * each sweep gets its OWN --out and --workdir; nothing is shared, so the
#     byte verifier's two trees can never be the same tree.
set -u
B=${1:?binary}
C=${2:?corpus}
M=${3:?mode}
O=${4:?out csv}
W=${5:?workdir}
[ -x "$B" ] || { echo "FATAL: no binary $B"; exit 3; }
cd "$HOME/git-repos/slang-uhdm" || exit 3
echo "GOLDEN_DEFER=[${GOLDEN_DEFER:-UNSET}]"
echo "== sweep $C/$M with $B -> $O"
SLANG_UHDM=$B timeout 21600 python3 scripts/verify_golden.py \
    --corpus "$C" --mode "$M" --jobs 2 --out "$O" --workdir "$W" 2>&1 | tail -14
bad=$(grep -rh '^slang:' "$W"/*/*/cmds.txt 2>/dev/null | awk '{print $2}' | sort -u | grep -vFx "$B" | head -3)
if [ -n "$bad" ]; then echo "FATAL: workdir $W names OTHER binaries: $bad"; exit 4; fi
echo "   cmds.txt binary VERIFIED: $B"
echo "SWEEP DONE $C/$M $B"
