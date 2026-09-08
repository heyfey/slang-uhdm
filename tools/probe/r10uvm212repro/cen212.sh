#!/bin/bash
# r10uvm212 — run ct212cen over the UVM row-modes of a verify_golden workdir and
# print golden's rows beside ours.  MEASUREMENT ONLY.
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# GUARDS:
#   * the golden path is read out of the row's OWN cmds.txt (never guessed), and
#     a row whose golden or ours is missing prints SKIP-NOFILE and is COUNTED —
#     a driver that reaches nothing must never read as perfection;
#   * the workdir comes from the environment/argument, never hard-coded, so this
#     script cannot read another pass's scratch.
#
#   usage: cen212.sh <workdir> <outdir> [--full]
set -u
WD=${1:?workdir}
OUT=${2:?outdir}
FULL=${3:-}
CEN=${CT212CEN:?set CT212CEN to the built ct212cen}
mkdir -p "$OUT" || exit 1
miss=0; did=0
for t in Scoreboard SeqDriver MiniAmiq SimpleUVM BuildUVMPkg; do
  for m in default testflags; do
    D=$(ls -d "$WD/$m/$t"-*/ 2>/dev/null | head -1)
    [ -n "$D" ] || { echo "SKIP-NOFILE $t/$m (no row dir)"; miss=$((miss+1)); continue; }
    G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$D/cmds.txt" | head -1)
    if [ -z "$G" ] || [ ! -f "$G/golden.uhdm" ] || [ ! -f "$D/slang.uhdm" ]; then
      echo "SKIP-NOFILE $t/$m (g=${G:-none})"; miss=$((miss+1)); continue
    fi
    "$CEN" "$G/golden.uhdm" $FULL > "$OUT/$t.$m.golden.txt" 2>&1
    "$CEN" "$D/slang.uhdm"  $FULL > "$OUT/$t.$m.ours.txt"   2>&1
    echo "== $t/$m"
    diff -u "$OUT/$t.$m.golden.txt" "$OUT/$t.$m.ours.txt" > "$OUT/$t.$m.diff" || true
    printf "   golden rows=%s ours rows=%s diff lines=%s\n" \
      "$(grep -c '^x' "$OUT/$t.$m.golden.txt" || true)" \
      "$(grep -c '^x' "$OUT/$t.$m.ours.txt" || true)" \
      "$(grep -c '^[-+]' "$OUT/$t.$m.diff" || true)"
    did=$((did+1))
  done
done
echo "-- censused=$did SKIP-NOFILE=$miss"
