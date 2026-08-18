#!/usr/bin/env bash
# r10buvm16 — verify_golden sweeps, ONE AT A TIME at --jobs 2, each with its OWN
# --out and --workdir, GOLDEN_DEFER left UNSET and echoed, and every workdir's
# cmds.txt re-read to prove which binary actually ran.
#
#   usage: sweeps16.sh <binary> <corpus> <outcsv> <workdir>
#
# GUARDS (each an ops trap this campaign has paid for):
#   * verify_golden.py SILENTLY DEFAULTS SLANG_UHDM to the MAIN-TREE binary, so
#     it is exported here AND re-read out of every workdir's own cmds.txt.
#   * THE EMPTY-WORKDIR GUARD: the cmds.txt binary check is a `grep -v`, and an
#     EMPTY workdir makes it find nothing and print "VERIFIED".  A guard that
#     passes on nothing is worse than no guard, so the file count is asserted.
#   * verify_golden.py records rc=139 SEGFAULTS as SLANG_REJECT wearing the last
#     stderr warning — the status histogram in ct16rows.sh is the check.
set -u
B=${1:?binary}; C=${2:?corpus}; O=${3:?out csv}; W=${4:?workdir}
[ -x "$B" ] || { echo "FATAL: no binary $B"; exit 3; }
# VERIFIER FIX (r10vbuvm16): this line was a HARD-CODED PASS WORKTREE, so the
# driver could not be re-run by any other operator -- and if that path still
# existed holding a DIFFERENT checkout it would have swept the wrong tree.
# It now defaults to the worktree THIS SCRIPT LIVES IN and takes $REPO.
REPO=${REPO:-$(cd "$(dirname "$0")/../../.." && pwd)}
[ -f "$REPO/scripts/verify_golden.py" ] || { echo "FATAL: $REPO is not a slang-uhdm worktree"; exit 3; }
cd "$REPO" || exit 3
echo "== $(date +%T) sweep $C with $B -> $O  (GOLDEN_DEFER=[${GOLDEN_DEFER:-UNSET}])"
SLANG_UHDM=$B timeout 43200 python3 scripts/verify_golden.py \
    --corpus "$C" --mode both --jobs 2 --out "$O" --workdir "$W" 2>&1 | tail -14
ncmd=$(ls "$W"/*/*/cmds.txt 2>/dev/null | wc -l)
[ "$ncmd" -gt 0 ] || { echo "FATAL: workdir $W has NO cmds.txt -- the sweep reached nothing"; exit 5; }
echo "   cmds.txt files: $ncmd"
bad=$(grep -rh '^slang:' "$W"/*/*/cmds.txt 2>/dev/null | awk '{print $2}' | sort -u | grep -vFx "$B" | head -3)
if [ -n "$bad" ]; then echo "FATAL: workdir $W names OTHER binaries: $bad"; exit 4; fi
echo "   cmds.txt binary VERIFIED: $B"
echo "SWEEP DONE $C $B $(date +%T)"
