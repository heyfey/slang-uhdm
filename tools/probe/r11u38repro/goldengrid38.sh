#!/usr/bin/env bash
# r11u38 GOLDEN GRID — § dimMemberSelBinFold38 + § paNameCopiesSrcConst38.
#
# Every arm is compiled by BOTH producers (the PINNED Surelog v1.87 and a
# slang-uhdm binary named on the command line) and scored cell by cell by the
# two census readers beside this script.  LHS is ALWAYS golden.
#
#   usage: goldengrid38.sh <slang-uhdm binary> [outdir]
#
# CONTROLS, both mandatory and both printed:
#   * EVERY arm records BOTH rcs and Surelog's own [FATAL]/[ERROR] counts.  An
#     arm whose compile fails teaches error recovery, not golden, and is
#     flagged ARM COMPILED NOTHING.
#   * NEGATIVE CONTROL `zz` names a source file that does not exist: it must
#     read rc!=0 and be the ONLY compiled-nothing arm.
#   * POSITIVE CONTROL: `g1_memsel38` must yield at least one golden cell whose
#     encoding is `BIN:` ct 3 and `g2_paenc38` at least one golden
#     `param_assign` Rhs at ct 7 — a grid that reaches no cell of either law
#     must never read as perfection.
set -u
BIN=${1:?slang-uhdm binary}
OUT=${2:-$(mktemp -d /tmp/r11u38grid.XXXXXX)}
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
HERE=$(cd "$(dirname "$0")" && pwd)
[ -x "$BIN" ] || { echo "FATAL: no slang-uhdm at $BIN"; exit 3; }
[ -x "$SL" ]  || { echo "FATAL: no surelog at $SL"; exit 3; }
[ -x "$DUMP" ]|| { echo "FATAL: no uhdm-dump at $DUMP"; exit 3; }
mkdir -p "$OUT" || exit 3
echo "grid outdir: $OUT"
echo "surelog:     $SL"
echo "slang-uhdm:  $BIN  ($(md5sum "$BIN" | cut -d' ' -f1))"
nothing=0; arms=0
run() {   # run <arm> <srcfile>
  local n=$1 f=$2
  arms=$((arms+1))
  rm -rf "$OUT/o_$n"
  "$SL" -parse -nobuiltin -nocache -sv "$f" -o "$OUT/o_$n" > "$OUT/$n.slog" 2>&1
  local grc=$?
  "$BIN" "$f" --single-unit -o "$OUT/$n.ours.uhdm" > "$OUT/$n.olog" 2>&1
  local orc=$?
  local fat err
  fat=$(grep -c '\[FATAL' "$OUT/$n.slog"; true)
  err=$(grep -c '\[ERROR' "$OUT/$n.slog"; true)
  printf '%-14s golden_rc=%-3s ours_rc=%-3s FATAL=%s ERROR=%s\n' \
         "$n" "$grc" "$orc" "$fat" "$err"
  if [ ! -f "$OUT/o_$n/slpp_all/surelog.uhdm" ] || [ ! -f "$OUT/$n.ours.uhdm" ]; then
    echo "   !! ARM COMPILED NOTHING"; nothing=$((nothing+1)); return
  fi
  "$DUMP" "$OUT/o_$n/slpp_all/surelog.uhdm" > "$OUT/$n.g.dump" 2>&1
  "$DUMP" "$OUT/$n.ours.uhdm"               > "$OUT/$n.o.dump" 2>&1
}

run g1_memsel38 "$HERE/grid/g1_memsel38.sv"
echo '--- g1: every size-form unpacked dim whose bound is a struct-param member select'
python3 "$HERE/dimcen38.py" "$OUT/g1_memsel38.g.dump" "$OUT/g1_memsel38.o.dump"

run g2_paenc38 "$HERE/grid/g2_paenc38.sv"
echo '--- g2: param_assign Rhs, DEFINITION listing'
python3 "$HERE/pacen38.py" "$OUT/g2_paenc38.g.dump" "$OUT/g2_paenc38.o.dump" 'work@m.'
echo '--- g2: param_assign Rhs, ELABORATED listing (this law must not move it)'
python3 "$HERE/pacen38.py" "$OUT/g2_paenc38.g.dump" "$OUT/g2_paenc38.o.dump" 'work@top.'
echo '--- g2: the package listing itself'
python3 "$HERE/pacen38.py" "$OUT/g2_paenc38.g.dump" "$OUT/g2_paenc38.o.dump" 'ip::'

run g3_home38 "$HERE/grid/g3_home38.sv"
echo '--- g3: the HOLDER and the source ENCODING (enum / string / real / cross-package / interface)'
python3 "$HERE/pacen38.py" "$OUT/g3_home38.g.dump" "$OUT/g3_home38.o.dump"

echo '--- NEGATIVE CONTROL: an arm whose compile reaches nothing'
run zz "$HERE/grid/no_such_source_file.sv"

pos1=$(grep -c '|BIN:00000000000000000000000000000100' "$OUT/g1_memsel38.g.dump"; true)
pos2=$(grep -c '|vpiConstType:7' "$OUT/g2_paenc38.g.dump"; true)
echo
echo "-- arms=$arms compiled-nothing=$nothing (must be exactly 1: the zz control)"
echo "-- POSITIVE CONTROL g1 (golden BIN member fold present): $pos1  (must be >=1)"
echo "-- POSITIVE CONTROL g2 (golden ct 7 param_assign present): $pos2  (must be >=1)"
[ "$nothing" -eq 1 ] && [ "$pos1" -ge 1 ] && [ "$pos2" -ge 1 ] \
  && echo "GRID CONTROLS: PASS" || { echo "GRID CONTROLS: FAIL"; exit 5; }
