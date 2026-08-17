#!/usr/bin/env bash
# r10buvm11 — the four sweeps, ONE AT A TIME at --jobs 2, each with its OWN
# --out and --workdir, GOLDEN_DEFER left UNSET and echoed, and every workdir's
# cmds.txt re-read to prove which binary actually ran.
#
# GUARDS (each an ops trap this campaign has paid for):
#   * verify_golden.py SILENTLY DEFAULTS SLANG_UHDM to the MAIN-TREE binary, so
#     it is exported here AND re-read out of every workdir's own cmds.txt.
#   * THE EMPTY-WORKDIR GUARD: the cmds.txt binary check is a `grep -v`, and an
#     EMPTY workdir makes it find nothing and print "VERIFIED".  A guard that
#     passes on nothing is worse than no guard, so the file count is asserted.
#   * verify_golden.py records rc=139 SEGFAULTS as SLANG_REJECT wearing the last
#     stderr warning — the status histogram in ct11rows.sh is the check.
set -u
cd "$HOME/git-repos/slang-uhdm" || exit 3
run() {
  B=$1; C=$2; O=$3; W=$4
  [ -x "$B" ] || { echo "FATAL: no binary $B"; exit 3; }
  echo "== $(date +%T) sweep $C with $B -> $O  (GOLDEN_DEFER=[${GOLDEN_DEFER:-UNSET}])"
  SLANG_UHDM=$B timeout 43200 python3 scripts/verify_golden.py \
      --corpus "$C" --mode both --jobs 2 --out "$O" --workdir "$W" 2>&1 | tail -12
  ncmd=$(ls "$W"/*/*/cmds.txt 2>/dev/null | wc -l)
  [ "$ncmd" -gt 0 ] || { echo "FATAL: workdir $W has NO cmds.txt -- the sweep reached nothing"; exit 5; }
  echo "   cmds.txt files: $ncmd"
  bad=$(grep -rh '^slang:' "$W"/*/*/cmds.txt 2>/dev/null | awk '{print $2}' | sort -u | grep -vFx "$B" | head -3)
  if [ -n "$bad" ]; then echo "FATAL: workdir $W names OTHER binaries: $bad"; exit 4; fi
  echo "   cmds.txt binary VERIFIED: $B"
}
run /tmp/r10buvm11_bin_patched  uhdm2rtlil /tmp/r10buvm11_u2r_patched.csv  /tmp/r10buvm11_wdu_patched
run /tmp/r10buvm11_bin_pristine uhdm2rtlil /tmp/r10buvm11_u2r_pristine.csv /tmp/r10buvm11_wdu_pristine
run /tmp/r10buvm11_bin_patched  surelog    /tmp/r10buvm11_sl_patched.csv   /tmp/r10buvm11_wds_patched
run /tmp/r10buvm11_bin_pristine surelog    /tmp/r10buvm11_sl_pristine.csv  /tmp/r10buvm11_wds_pristine
echo "ALL SWEEPS DONE $(date +%T)"
