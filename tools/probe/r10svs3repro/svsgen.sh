#!/bin/bash
# r10svs3repro/svsgen.sh — regenerate the SVSwitch pair (golden + ours) for BOTH
# modes through THE HARNESS ITSELF (scripts/verify_golden.py --filter '^SVSwitch$'),
# so the argv on both sides are byte-for-byte the ones the committed baseline
# rows were produced with.  Hand-rolling the `testflags` translation is exactly
# the kind of drift that makes a localization unfalsifiable, so it is not done
# here: the harness builds it.
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.  uhdm-cmp takes
# (golden.uhdm, ours.uhdm) in that order.
#
#   usage: svsgen.sh <outdir> <slang-binary>
#     prints, per mode, the golden path, our path, dump content +/-, and the
#     cmp HEAD DEPTH with its head count.
#
# GUARDS (each one an ops trap this campaign has paid for):
#   * uhdm-cmp EXITS 0 WHEN AN INPUT FILE IS MISSING, so a bare `uhdm-cmp a b &&
#     echo PASS` prints PASS on a run that produced NOTHING.  Both databases are
#     existence-checked before cmp runs; a missing one is a hard exit 6.
#   * uhdm-dump's FIRST LINE is the DATABASE PATH and always differs, so both
#     dumps go through `sed 1d`; every +/- figure here is real content.
#   * the slang binary is NEVER defaulted to the main-tree build silently: it is
#     a required argument and its md5 is printed on every run.
#   * uhdm-cmp / uhdm-dump are existence-checked and absolute.
#   * GOLDEN_CACHE is left at its default on purpose: the golden side is
#     immutable per (surelog binary, dir, argv) and the cache is what keeps two
#     runs of this script comparable.
set -u
OUT=${1:?outdir}
BIN=${2:?slang binary}
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE"/../../.. && pwd)
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}

[ -x "$BIN" ] || { echo "FATAL: slang binary not executable: $BIN"; exit 3; }
[ -x "$CMP" ] || { echo "FATAL: uhdm-cmp not executable: $CMP"; exit 3; }
[ -x "$DUMP" ] || { echo "FATAL: uhdm-dump not executable: $DUMP"; exit 3; }
[ -f "$ROOT/scripts/verify_golden.py" ] || { echo "FATAL: no harness"; exit 3; }

echo "SLANG=$BIN  md5=$(md5sum "$BIN" | cut -d' ' -f1)"
mkdir -p "$OUT" || exit 1
SLANG_UHDM=$BIN python3 "$ROOT/scripts/verify_golden.py" --corpus surelog \
    --mode both --jobs 2 --filter '^SVSwitch$' \
    --out "$OUT/row.csv" --workdir "$OUT/wd" > "$OUT/harness.log" 2>&1
echo "harness rc=$?"
grep -E '^SVSwitch' "$OUT/row.csv" || { echo "NO ROW"; exit 6; }

for M in default testflags; do
    W=$(ls -d "$OUT"/wd/$M/SVSwitch-* 2>/dev/null | head -1)
    [ -n "${W:-}" ] || { echo "$M: NO WORKDIR"; exit 6; }
    O=$W/slang.uhdm
    # The golden is the cache hit named in cmds.txt, or the local slpp_all copy.
    G=$(ls "$W"/slpp_all/*.uhdm "$W"/slpp_unit/*.uhdm 2>/dev/null | head -1)
    if [ -z "${G:-}" ]; then
        C=$(sed -n 's/^surelog: (golden cache hit \(.*\))$/\1/p' "$W/cmds.txt")
        G=$(ls "$C"/*.uhdm 2>/dev/null | head -1)
    fi
    [ -n "${G:-}" ] && [ -f "$G" ] || { echo "$M: NO_OUTPUT golden absent"; exit 6; }
    [ -f "$O" ] || { echo "$M: NO_OUTPUT ours absent"; exit 6; }
    echo "== $M"
    echo "  GOLDEN=$G bytes=$(stat -c %s "$G")"
    echo "  OURS=$O bytes=$(stat -c %s "$O")"
    "$DUMP" "$G" | sed '1d' > "$OUT/$M.g.dump" 2>&1
    "$DUMP" "$O" | sed '1d' > "$OUT/$M.o.dump" 2>&1
    [ -s "$OUT/$M.g.dump" ] || { echo "$M: golden dump empty"; exit 6; }
    [ -s "$OUT/$M.o.dump" ] || { echo "$M: ours dump empty"; exit 6; }
    echo "  g.dump lines=$(wc -l < "$OUT/$M.g.dump")  o.dump lines=$(wc -l < "$OUT/$M.o.dump")"
    RAW=$(diff -u "$OUT/$M.g.dump" "$OUT/$M.o.dump" | grep -c '^[-+]')
    echo "  dump content +/- = $((RAW - 2))  (raw $RAW minus 2 diff -u headers)"
    "$CMP" "$G" "$O" > "$OUT/$M.cmp.txt" 2>&1
    echo "  cmp rc=$?  cmp HEAD DEPTH=$(wc -l < "$OUT/$M.cmp.txt")  heads=$(grep -c '^LHS:' "$OUT/$M.cmp.txt")"
    echo "$G" > "$OUT/$M.goldenpath"
    echo "$O" > "$OUT/$M.ourspath"
done
echo "OUT=$OUT"
