#!/usr/bin/env bash
# r10buvm3 — the FOUR sweeps gates 3/4/5 need, run one at a time at --jobs 2.
#
#   usage: sweeps.sh <patched-binary> <pristine-binary> <tag>
#
# GUARDS, each an ops trap this campaign has paid for:
#   * verify_golden.py SILENTLY DEFAULTS SLANG_UHDM to the MAIN-TREE binary, so
#     it is exported here AND re-read out of every workdir's own cmds.txt
#     afterwards; a sweep whose cmds.txt names a different binary is fatal.
#   * GOLDEN_DEFER is left UNSET (the five memory giants must read DEFERRED in
#     both modes exactly as the committed baselines do).
#   * each sweep gets its OWN --out and --workdir; nothing is shared.
set -u
P=${1:?patched binary}
R=${2:?pristine binary}
T=${3:-r10buvm3}
for b in "$P" "$R"; do [ -x "$b" ] || { echo "FATAL: no binary $b"; exit 3; }; done
cd "$HOME/git-repos/slang-uhdm" || exit 3
echo "GOLDEN_DEFER=[${GOLDEN_DEFER:-UNSET}]"
run() {  # run <binary> <corpus> <mode> <outcsv> <workdir>
  echo "== sweep $2/$3 with $1"
  SLANG_UHDM=$1 timeout 7200 python3 scripts/verify_golden.py \
      --corpus "$2" --mode "$3" --jobs 2 --out "$4" --workdir "$5" 2>&1 | tail -14
  local bad
  bad=$(grep -rh '^slang:' "$5"/*/*/cmds.txt 2>/dev/null | awk '{print $2}' | sort -u | grep -vFx "$1" | head -3)
  if [ -n "$bad" ]; then echo "FATAL: workdir $5 names OTHER binaries: $bad"; exit 4; fi
  echo "   cmds.txt binary VERIFIED: $1"
}
run "$P" uhdm2rtlil testflags "/tmp/${T}_u2r_patched.csv" "/tmp/${T}_wd_u2r_patched"
run "$R" uhdm2rtlil testflags "/tmp/${T}_u2r_pris.csv"    "/tmp/${T}_wd_u2r_pris"
run "$P" surelog     both     "/tmp/${T}_sl_patched.csv"  "/tmp/${T}_wd_sl_patched"
run "$R" surelog     both     "/tmp/${T}_sl_pris.csv"     "/tmp/${T}_wd_sl_pris"
echo "ALL FOUR SWEEPS DONE"
