#!/usr/bin/env bash
# r10uvm163 — THE COIN CHECK.  Scoreboard/default is RESUME.md §9's documented
# ~50/50 nondeterministic row, so a head-line count measured ONCE proves
# nothing.  This runs ONE binary on the Scoreboard row N times and prints, per
# run, the database sha256, the cmp line count and the head count — so the
# claim "145 -> 95" is a distribution, not a coin toss.
# MEASUREMENT ONLY.  LHS is ALWAYS golden(Surelog); the judge is uhdm-cmp.
#   usage: BIN=<binary> coin163.sh <outdir> [N]
# GUARD: the golden path is read out of a REAL cmds.txt (passed as GOLDEN), and
# both sides are existence-checked; a missing side prints SKIP and is counted.
set -u
OUT=${1:?outdir}; N=${2:-5}
BIN=${BIN:?set BIN}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
GOLDEN=${GOLDEN:?set GOLDEN to the golden.uhdm}
SRC=${SRC:-$HOME/git-repos/Surelog/third_party/tests/Scoreboard}
UVM=${UVM:-$HOME/git-repos/Surelog/third_party/UVM}
[ -x "$BIN" ] || { echo "FATAL: no binary $BIN"; exit 3; }
[ -f "$GOLDEN" ] || { echo "FATAL: no golden $GOLDEN"; exit 3; }
mkdir -p "$OUT" || exit 1
cp "$SRC"/design.sv "$SRC"/testbench.sv "$OUT/" || exit 1
skip=0
for i in $(seq 1 "$N"); do
  ( cd "$OUT" && "$BIN" "+incdir+.+$UVM/uvm-1.2/src/+$UVM/svunit_base" \
      "$UVM/uvm-1.2/src/uvm_pkg.sv" "$UVM/svunit_base/svunit_pkg.sv" \
      design.sv testbench.sv --single-unit -o "run$i.uhdm" > "run$i.log" 2>&1 </dev/null )
  rc=$?
  if [ ! -f "$OUT/run$i.uhdm" ]; then
    echo "run $i SKIP rc=$rc (no database)"; skip=$((skip+1)); continue
  fi
  "$CMP" "$GOLDEN" "$OUT/run$i.uhdm" > "$OUT/run$i.cmp" 2>&1
  printf "run %-2s rc=%-3s sha=%s cmplines=%-5s heads=%s\n" "$i" "$rc" \
    "$(sha256sum "$OUT/run$i.uhdm" | cut -c1-12)" \
    "$(wc -l < "$OUT/run$i.cmp")" "$(grep -c '^LHS:' "$OUT/run$i.cmp"; true)"
done
echo "-- runs=$N SKIPPED=$skip distinct-databases=$(sha256sum "$OUT"/run*.uhdm 2>/dev/null | cut -c1-12 | sort -u | wc -l)"
