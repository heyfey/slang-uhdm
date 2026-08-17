#!/usr/bin/env bash
# r10buvm6 — PRISTINE-vs-PRISTINE control for the two RESIDUE movers.
#
# attrib6.sh reported RESIDUE (a change stripdollar.py cannot attribute to a `$`
# constant) on exactly two of the seven movers: default/Scoreboard and
# testflags/SeqDriver.  The standing rules already record those two rows as a
# BOTH-SIDES FLAKE ("Scoreboard COIN; SeqDriver/testflags showed both-sides flake
# once").  A note is not a measurement, so this script MEASURES it: the SAME
# PRISTINE BINARY is swept TWICE, into two independent workdirs, and attrib6.sh
# is run on the two pristine trees.  If the same residue class appears
# pristine-vs-pristine, the residue is the emitter's own run-to-run flake and not
# this pass's law.
#
#   usage: detsweep6.sh <pristine-binary> <outroot>
#
# GUARD: each sweep gets its OWN --out and --workdir, and the filter is anchored
# so it selects EXACTLY the two test names (a bare substring would also drag in
# any test whose name merely contains them).
set -u
R=${1:?pristine binary}
O=${2:?outroot}
[ -x "$R" ] || { echo "FATAL: no binary $R"; exit 3; }
cd "$HOME/git-repos/slang-uhdm" || exit 3
echo "GOLDEN_DEFER=[${GOLDEN_DEFER:-UNSET}]  BIN=$R md5=$(md5sum "$R" | cut -d' ' -f1)"
for side in A B; do
  echo "== pristine sweep $side"
  SLANG_UHDM=$R timeout 7200 python3 scripts/verify_golden.py \
      --corpus surelog --mode both --jobs 2 \
      --filter '^(Scoreboard|SeqDriver)$' \
      --out "$O/$side.csv" --workdir "$O/$side" 2>&1 | tail -8
  bad=$(grep -rh '^slang:' "$O/$side"/*/*/cmds.txt 2>/dev/null | awk '{print $2}' |
        sort -u | grep -vFx "$R" | head -3)
  [ -n "$bad" ] && { echo "FATAL: workdir names OTHER binaries: $bad"; exit 4; }
  echo "   cmds.txt binary VERIFIED: $R"
done
echo "BOTH PRISTINE SWEEPS DONE"
