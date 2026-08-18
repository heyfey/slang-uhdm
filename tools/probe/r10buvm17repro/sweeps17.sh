#!/usr/bin/env bash
# r10buvm17 — verify_golden sweeps, each with its OWN --out and --workdir,
# GOLDEN_DEFER left UNSET and echoed, and every workdir's cmds.txt re-read to
# prove which binary actually ran.
#
#   usage: sweeps17.sh <binary> <corpus> <outcsv> <workdir>
#
# GUARDS (each an ops trap this campaign has paid for):
#   * verify_golden.py SILENTLY DEFAULTS SLANG_UHDM to the MAIN-TREE binary, so
#     it is exported here AND re-read out of every workdir's own cmds.txt.
#   * THE EMPTY-WORKDIR GUARD: the cmds.txt binary check is a `grep -v`, and an
#     EMPTY workdir makes it find nothing and print "VERIFIED" -- the file count
#     is asserted so a guard cannot pass on nothing.
#   * verify_golden.py records rc=139 SEGFAULTS as SLANG_REJECT wearing the last
#     stderr warning -- the status histogram in ct8rows.sh is the check.
#   * $REPO is derived from THIS SCRIPT'S location, never hard-coded to a pass
#     worktree (r10vbuvm16's defect 2), and asserted to be a slang-uhdm tree.
set -u
B=${1:?binary}; C=${2:?corpus}; O=${3:?out csv}; W=${4:?workdir}
[ -x "$B" ] || { echo "FATAL: no binary $B"; exit 3; }
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
