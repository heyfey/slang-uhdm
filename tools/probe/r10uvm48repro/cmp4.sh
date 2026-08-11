#!/bin/bash
# r10uvm48 — the FULL uhdm-cmp output for each of the UVM-4 out of a sweep
# workdir.  LHS is ALWAYS golden(Surelog), RHS is ALWAYS ours — uhdm-cmp is
# invoked as (golden.uhdm, ours.uhdm) and never the other way round.
#
# POSITIVE CONTROL, because "a driver that cannot find its probe reports
# PERFECTION": every step that can be missing is FATAL and named.  A test whose
# workdir or golden is absent prints MISSING and sets rc=3; it never prints a
# line count that could be mistaken for a small residue.
#   usage: cmp4.sh <sweep-workdir> <tag> [mode]
set -u
WD=${1:?usage: cmp4.sh <sweep-workdir> <tag> [mode]}
TAG=${2:?}
MODE=${3:-default}
CMP=/home/heyfey/.local/bin/uhdm-cmp
[ -x "$CMP" ] || { echo "FATAL: no uhdm-cmp at $CMP"; exit 3; }
[ -d "$WD/$MODE" ] || { echo "FATAL: no $WD/$MODE"; exit 3; }
rc=0
for T in SeqDriver SimpleUVM Scoreboard BuildUVMPkg; do
  D=$(ls -d "$WD/$MODE"/$T-* 2>/dev/null | head -1)
  if [ -z "$D" ]; then echo "$T MISSING workdir"; rc=3; continue; fi
  if [ ! -s "$D/slang.uhdm" ]; then echo "$T MISSING slang.uhdm"; rc=3; continue; fi
  GD=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)
  if [ -z "$GD" ] || [ ! -s "$GD/golden.uhdm" ]; then
    echo "$T MISSING golden"; rc=3; continue; fi
  O=/tmp/r10uvm48_cmp_${TAG}_${MODE}_$T.txt
  "$CMP" "$GD/golden.uhdm" "$D/slang.uhdm" > "$O" 2>&1
  echo "$T rc=$? lines=$(wc -l < "$O") heads=$(grep -c '^LHS:' "$O") -> $O"
done
exit $rc
