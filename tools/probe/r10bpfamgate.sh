#!/bin/bash
# r10bpfam: HARD GATE.  1=goldens 2=u2r testflags 3=surelog both modes.
# Usage: r10bpfamgate.sh <tag> [1|2|3|all]
cd /home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_8a9f0e85-35c-1 || exit 1
export SLANG_UHDM=$PWD/build/slang-uhdm
TAG=$1; WHAT=${2:-all}
if [ "$WHAT" = 1 ] || [ "$WHAT" = all ]; then
  echo "=== GOLDENS"
  bash tests/check_goldens.sh 2>&1 | tail -3
fi
if [ "$WHAT" = 2 ] || [ "$WHAT" = all ]; then
  echo "=== U2R testflags"
  rm -rf /tmp/r10bpfam_gw2$TAG
  timeout 3600 python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags \
    --out /tmp/r10bpfam_g2$TAG.csv --workdir /tmp/r10bpfam_gw2$TAG --jobs 4 2>&1 | tail -12
  diff results/gate_uhdm2rtlil.csv /tmp/r10bpfam_g2$TAG.csv > /tmp/r10bpfam_g2$TAG.diff
  echo "u2r diff lines: $(grep -c '^[<>]' /tmp/r10bpfam_g2$TAG.diff)"
  cat /tmp/r10bpfam_g2$TAG.diff
fi
if [ "$WHAT" = 3 ] || [ "$WHAT" = all ]; then
  echo "=== SURELOG both modes"
  rm -rf /tmp/r10bpfam_gw3$TAG
  timeout 7200 python3 scripts/verify_golden.py --corpus surelog --mode both \
    --out /tmp/r10bpfam_g3$TAG.csv --workdir /tmp/r10bpfam_gw3$TAG --jobs 4 2>&1 | tail -20
  diff results/golden_surelog.csv /tmp/r10bpfam_g3$TAG.csv > /tmp/r10bpfam_g3$TAG.diff
  echo "surelog diff lines: $(grep -c '^[<>]' /tmp/r10bpfam_g3$TAG.diff)"
  cat /tmp/r10bpfam_g3$TAG.diff
fi
echo "== gate done"
