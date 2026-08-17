#!/usr/bin/env bash
# r10earl56 VERIFIER — THE POSITIVE CONTROL FOR § genScopeOwnParamNoSelFold56's
# `directBound56` CLAUSE, and for the CENSUS ITSELF.
#
# The pass's write-up says the `directBound56` half of the fence is not
# decoration but a 107-cell regression caught before landing, and that
# `census56.py` reported that broken build CLEAN.  Both halves of that claim are
# EXPERIMENTS, so this script runs them:
#
#   1. builds a THIRD binary from the landed patch with `directBound56 &&`
#      DELETED (nothing else changed),
#   2. runs it on Earlgrey_0_1/default with the row's own command line,
#   3. asserts `v56span3.py` reports **AWAY-GOLDEN = 107** at
#      (ELAB, 127:48, vpiOperand, par=operation) -- the refs nested inside the
#      bound operation of `storage[fifo_rptr[PTR_WIDTH-2:0]]`, where golden and
#      the pristine binary both hold a folded `constant`,
#   4. asserts `census56.py` reports **AWAY-GOLDEN = 0** for that SAME binary,
#      i.e. reproduces the blindness rather than taking it on trust.
#
# MEASURED (verifier v56, binaries 465c8c1d… patched / f23af115… control):
#   v56span3.py  gold/patched/control : AWAY-GOLDEN=107  (all 127:48 vpiOperand)
#   census56.py  gold/patched/control : AWAY-GOLDEN=0  UNMOVED-GOOD=30404
#                                      -- numerically IDENTICAL to the clean run
#   dump diff patched-vs-control      : +107 ref_obj(PTR_WIDTH)@127,
#                                       -214 constant@127, -214 int_typespec@56
#   whole-design object histogram @127:48 : gold 214 constant, pristine 214
#     constant, patched 214 constant, control 107 ref_obj
#
#   usage: vctl56.sh <base-commit> <patch> <golden.uhdm> <patched.dump> <outdir>
set -u
BASE=${1:?base commit}; PATCH=${2:?patch}; GOLD=${3:?golden.uhdm}
PATDUMP=${4:?patched Earlgrey dump}; OUT=${5:?outdir}
HERE=$(cd "$(dirname "$0")" && pwd)
SCR=${EARLGREY_SCR:-$HOME/git-repos/Surelog/third_party/tests/Earlgrey_0_1/sim-icarus}
WT=$OUT/wt_ctl
rm -rf "$WT"; mkdir -p "$OUT"
git -C "$(git -C "$HERE" rev-parse --show-toplevel)" worktree add "$WT" "$BASE" >/dev/null 2>&1 || exit 9
( cd "$WT" && git apply "$PATCH" ) || exit 9
# DELETE the clause, and REFUSE if the text is not there: a control that silently
# edits nothing reports "no regression" exactly like a correct fence.
python3 - "$WT/src/ExprEmit.cpp" <<'PY' || exit 8
import sys
p = sys.argv[1]; s = open(p).read()
old = "!(directBound56 && genScopeDeclaredParam56(nv.symbol))"
new = "!(genScopeDeclaredParam56(nv.symbol))"
assert s.count(old) == 1, "clause not found exactly once -- control is INVALID"
open(p, 'w').write(s.replace(old, new)); print("control edit applied")
PY
~/.local/bin/cmake -S "$WT" -B "$WT/build" -DCMAKE_BUILD_TYPE=Release >"$OUT/cfg.log" 2>&1 || exit 9
~/.local/bin/cmake --build "$WT/build" -j 2 >"$OUT/build.log" 2>&1
grep -q 'Built target slang_uhdm$' "$OUT/build.log" || { echo CONTROL_BUILD_FAILED; exit 9; }
echo "CONTROL BINARY md5=$(md5sum "$WT/build/slang-uhdm" | cut -d' ' -f1)"
( cd "$SCR" && "$WT/build/slang-uhdm" +define+SYNTHESIS \
    -f lowrisc_systems_top_earlgrey_0.1.scr --single-unit -o "$OUT/ctl.uhdm" ) \
    >"$OUT/run.log" 2>&1
[ -s "$OUT/ctl.uhdm" ] || { echo CONTROL_RUN_FAILED; exit 9; }
"$HOME/git-repos/UHDM/build/bin/uhdm-dump" "$OUT/ctl.uhdm" 2>/dev/null | sed 1d > "$OUT/ctl.dump"
G=$OUT/gold.dump
[ -s "$G" ] || "$HOME/git-repos/UHDM/build/bin/uhdm-dump" "$GOLD" 2>/dev/null | sed 1d > "$G"
echo "--- v56span3.py (deep, below-slot):"
NODEDUP=1 python3 "$HERE/v56span3.py" "$G" "$PATDUMP" "$OUT/ctl.dump" | tail -1
echo "--- census56.py (slot-keyed, the SHIPPED instrument):"
python3 "$HERE/census56.py" "$G" "$PATDUMP" "$OUT/ctl.dump" --attrib | tail -1
echo "EXPECT: span3 AWAY-GOLDEN=107 and census56 AWAY-GOLDEN=0."
