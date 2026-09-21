#!/bin/bash
# r11u81 GATE DRIVER — all five gates, per binary, with the ops traps closed.
#
#   usage: gates81.sh <tag> <binary>
#
# * SLANG_UHDM is EXPORTED explicitly (both `verify_golden.py` and
#   `check_goldens.sh` silently default it to the MAIN TREE binary).
# * every workdir and --out is THIS PASS's own, named by tag; nothing is read
#   from another pass's controls.
# * the binary is used at its FROZEN immutable path.
# * THE TAG MUST BE THE SAME LENGTH FOR BOTH BINARIES.  The emitted database
#   EMBEDS the workdir path, so two sweeps whose workdir names differ in LENGTH
#   produce byte-different databases everywhere and `byteverify.sh` — a plain
#   `cmp` — then reports every path as a mover.  MEASURED here: the same
#   pristine binary run on `y1_sdval76` under tags `aaa` and `ccc` gives files
#   that differ in exactly THREE bytes, `a`/`a`/`a` against `c`/`c`/`c`, and
#   under `aaa` and `bbbb` the sizes differ by one.  This pass therefore uses
#   `pris` and `lawx`.
set -u
TAG=${1:?tag}
BIN=${2:?binary}
R=${R:-/tmp/r11u81_gates}
S=${S:-/home/heyfey/git-repos/slang-uhdm}
mkdir -p "$R"
export SLANG_UHDM="$BIN"
echo "=== $TAG  $BIN  md5=$(md5sum "$BIN" | cut -d' ' -f1)"

echo "--- goldens"
bash "$S/tests/check_goldens.sh" > "$R/gold.$TAG.txt" 2>&1
echo "  PASS=$(grep -c '^PASS' "$R/gold.$TAG.txt"; true) FAIL=$(grep -c '^FAIL' "$R/gold.$TAG.txt"; true)"

echo "--- uhdm2rtlil both modes"
python3 "$S/scripts/verify_golden.py" --corpus uhdm2rtlil --mode both \
    --jobs 3 --out "$R/u2r.$TAG.csv" --workdir "$R/wd_u2r_$TAG" \
    > "$R/u2r.$TAG.log" 2>&1
echo "  $(tail -3 "$R/u2r.$TAG.log" | tr '\n' ' ')"

echo "--- surelog both modes"
python3 "$S/scripts/verify_golden.py" --corpus surelog --mode both \
    --jobs 3 --out "$R/sl.$TAG.csv" --workdir "$R/wd_sl_$TAG" \
    > "$R/sl.$TAG.log" 2>&1
echo "  $(tail -3 "$R/sl.$TAG.log" | tr '\n' ' ')"

echo "--- cmds.txt audit (every invocation must name THIS binary)"
for w in "$R/wd_u2r_$TAG" "$R/wd_sl_$TAG"; do
  n=$(find "$w" -name cmds.txt | wc -l)
  mine=$(grep -rl -- "$BIN" $(find "$w" -name cmds.txt) 2>/dev/null | wc -l)
  main=$(grep -rl -- "$S/build/slang-uhdm" $(find "$w" -name cmds.txt) 2>/dev/null | wc -l)
  echo "  $(basename "$w"): cmds=$n naming-this-binary=$mine naming-MAIN-TREE=$main"
done
