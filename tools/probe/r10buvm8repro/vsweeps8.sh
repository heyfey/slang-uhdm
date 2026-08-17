#!/usr/bin/env bash
# vbuvm8 verifier sweeps: FOUR sweeps, one at a time, --jobs 2, GOLDEN_DEFER
# left UNSET, each with its OWN --out and --workdir.  The binary that actually
# ran is re-read out of every workdir's cmds.txt, and an EMPTY workdir is FATAL
# (a guard that passes on nothing is worse than no guard).
set -u
cd "${REPO:?set REPO to the worktree root}" || exit 3
run() {
  B=$1; C=$2; O=$3; W=$4
  [ -x "$B" ] || { echo "FATAL: no binary $B"; exit 3; }
  echo "== $(date +%T) sweep $C with $B -> $O (GOLDEN_DEFER=[${GOLDEN_DEFER:-UNSET}])"
  SLANG_UHDM=$B timeout 43200 python3 scripts/verify_golden.py \
      --corpus "$C" --mode both --jobs 2 --out "$O" --workdir "$W" 2>&1 | tail -12
  ncmd=$(ls "$W"/*/*/cmds.txt 2>/dev/null | wc -l)
  [ "$ncmd" -gt 0 ] || { echo "FATAL: workdir $W has NO cmds.txt"; exit 5; }
  echo "   cmds.txt files: $ncmd"
  bad=$(grep -rh '^slang:' "$W"/*/*/cmds.txt 2>/dev/null | awk '{print $2}' | sort -u | grep -vFx "$B" | head -3)
  [ -n "$bad" ] && { echo "FATAL: workdir $W names OTHER binaries: $bad"; exit 4; }
  echo "   cmds.txt binary VERIFIED: $B"
}
run /tmp/vbuvm8_bin_v1       uhdm2rtlil /tmp/vbuvm8_u2r_v1.csv  /tmp/vbuvm8_wdu_v1
run /tmp/vbuvm8_bin_pristine uhdm2rtlil /tmp/vbuvm8_u2r_pri.csv /tmp/vbuvm8_wdu_pri
run /tmp/vbuvm8_bin_v1       surelog    /tmp/vbuvm8_sl_v1.csv   /tmp/vbuvm8_wds_v1
run /tmp/vbuvm8_bin_pristine surelog    /tmp/vbuvm8_sl_pri.csv  /tmp/vbuvm8_wds_pri
echo "ALL SWEEPS DONE $(date +%T)"
