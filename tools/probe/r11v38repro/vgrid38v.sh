#!/usr/bin/env bash
# r11v38 — the VERIFIER's grid for § dimMemberSelBinFold38 + § paNameCopiesSrcConst38.
# Four arms written independently of the implementer's, each compiled by BOTH
# producers and scored gold x pristine x candidate, cell by cell.  LHS is
# ALWAYS golden (the pinned Surelog v1.87); the judge of a ROW is uhdm-cmp, and
# this instrument only reads dumps.
#
#   usage: vgrid38v.sh <pristine binary> <candidate binary> [outdir]
#
# THE ARMS, and what each one is FOR:
#   arms/v1_memsel.sv  the member-select size-form unpacked dim across eleven
#                      member shapes (first/middle/last, nested, enum, union,
#                      signed, a NET holder, TWO dims, a qualified package
#                      base, a localparam base, a generate scope) AND — the
#                      face that found this pass's defect — TWO INSTANCES of
#                      one module, the first OVERRIDDEN and the second at its
#                      default.
#   arms/v2_paenc.sv   a param default written as a bare NAME, over eleven
#                      source encodings x six declared target types, including
#                      a TRUNCATING target (`bit [3:0] P = SUB`), a negative
#                      source, a hop, a qualified spelling, an interface, a
#                      localparam and an OVERRIDDEN instance.
#   arms/v3_pa2.sv     the shapes the copy must DECLINE: a string, a real, an
#                      unknown (`4'bx1`), an enum source, and generate-scope
#                      localparams.
#   arms/v4_memsel2.sv the member-select dim at harder homes: a base declared
#                      by a TYPE parameter, a MODULE-LOCAL typedef, and an
#                      imported package struct read from TWO instances.
#
# CONTROLS, all printed, all mandatory:
#   * every arm records BOTH producers' rc and Surelog's own [FATAL]/[ERROR]
#     counts — an arm whose compile fails teaches error recovery, not golden;
#   * a NEGATIVE CONTROL arm names a file that does not exist and must be the
#     only compiled-nothing arm;
#   * a POSITIVE CONTROL asserts golden itself carries a `BIN:` member fold and
#     a ct-7 `param_assign`, so a grid that reaches no claimed cell can never
#     read as perfection.
set -u
PRIS=${1:?pristine binary}
CAND=${2:?candidate binary}
OUT=${3:-$(mktemp -d /tmp/r11v38grid.XXXXXX)}
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
HERE=$(cd "$(dirname "$0")" && pwd)
SCORE=${SCORE38:-$HERE/../r11u38repro/score38.py}
for x in "$PRIS" "$CAND" "$SL" "$DUMP"; do
  [ -x "$x" ] || { echo "FATAL: not executable: $x"; exit 3; }
done
[ -f "$SCORE" ] || { echo "FATAL: no scorer at $SCORE"; exit 3; }
mkdir -p "$OUT" || exit 3
echo "outdir:    $OUT"
echo "pristine:  $PRIS  ($(md5sum "$PRIS" | cut -d' ' -f1))"
echo "candidate: $CAND  ($(md5sum "$CAND" | cut -d' ' -f1))"
nothing=0; arms=0
run() {  # run <arm> <src> <census-mode ...>
  local n=$1 f=$2; shift 2
  arms=$((arms+1))
  rm -rf "$OUT/o_$n"
  "$SL" -parse -nobuiltin -nocache -sv "$f" -o "$OUT/o_$n" > "$OUT/$n.slog" 2>&1
  local grc=$?
  "$PRIS" "$f" --single-unit -o "$OUT/$n.p.uhdm" > "$OUT/$n.plog" 2>&1
  local prc=$?
  "$CAND" "$f" --single-unit -o "$OUT/$n.c.uhdm" > "$OUT/$n.clog" 2>&1
  local crc=$?
  printf '%-12s golden_rc=%-3s pristine_rc=%-3s candidate_rc=%-3s FATAL=%s ERROR=%s\n' \
    "$n" "$grc" "$prc" "$crc" \
    "$(grep -c '\[FATAL' "$OUT/$n.slog"; true)" \
    "$(grep -c '\[ERROR' "$OUT/$n.slog"; true)"
  if [ ! -f "$OUT/o_$n/slpp_all/surelog.uhdm" ] || [ ! -f "$OUT/$n.p.uhdm" ] \
     || [ ! -f "$OUT/$n.c.uhdm" ]; then
    echo "   !! ARM COMPILED NOTHING"; nothing=$((nothing+1)); return
  fi
  "$DUMP" "$OUT/o_$n/slpp_all/surelog.uhdm" > "$OUT/$n.g.dump" 2>&1
  "$DUMP" "$OUT/$n.p.uhdm" > "$OUT/$n.p.dump" 2>&1
  "$DUMP" "$OUT/$n.c.uhdm" > "$OUT/$n.c.dump" 2>&1
  local m
  for m in "$@"; do
    echo "   -- census $m"
    python3 "$SCORE" "$m" "$OUT/$n.g.dump" "$OUT/$n.p.dump" "$OUT/$n.c.dump" \
      | sed 's/^/      /'
  done
}
run v1_memsel   "$HERE/arms/v1_memsel.sv"   dim
run v2_paenc    "$HERE/arms/v2_paenc.sv"    pa
run v3_pa2      "$HERE/arms/v3_pa2.sv"      pa
run v4_memsel2  "$HERE/arms/v4_memsel2.sv"  dim
echo '--- NEGATIVE CONTROL: an arm that reaches nothing'
run zz "$HERE/arms/no_such_file.sv" dim
pos1=$(grep -c '|BIN:00000000000000000000000000000100' "$OUT/v1_memsel.g.dump"; true)
pos2=$(grep -c '|vpiConstType:7' "$OUT/v2_paenc.g.dump"; true)
echo
echo "-- arms=$arms compiled-nothing=$nothing (must be exactly 1: zz)"
echo "-- POSITIVE CONTROL golden BIN member fold present: $pos1 (>=1)"
echo "-- POSITIVE CONTROL golden ct-7 param_assign present: $pos2 (>=1)"
[ "$nothing" -eq 1 ] && [ "$pos1" -ge 1 ] && [ "$pos2" -ge 1 ] \
  && echo "GRID CONTROLS: PASS" || { echo "GRID CONTROLS: FAIL"; exit 5; }
