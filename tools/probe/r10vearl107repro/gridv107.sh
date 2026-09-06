#!/usr/bin/env bash
# r10vearl107 VERIFIER GRID DRIVER -- MEASUREMENT ONLY.  The official
# ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole acceptance judge.
#
# Runs THIS directory's seven adversarial arms through r10earl107repro's own
# grid107.sh (carried there, not duplicated here) with r10earl107repro's cen107
# census and score107.py scorer, so the verifier scores the arms on exactly the
# instrument the implementer's numbers were produced on.
#
#   PATCHED_BIN=<bin> PRISTINE_BIN=<bin> CEN_BIN=<cen107> bash gridv107.sh <outdir>
#
# GUARDS inherited from grid107.sh: every producer's rc recorded; a missing
# database printed as REJECT and COUNTED; children get </dev/null; the -top is
# read from TOPS.txt.  cen107 is built with
#   g++ -O2 -std=c++17 ../r10earl107repro/cen107.cpp -I ~/.local/include \
#       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cen107
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
IMPL=$HERE/../r10earl107repro
OUT=${1:?outdir}
ARM_DIR=$HERE bash "$IMPL/grid107.sh" "$OUT" "$HERE"/v?_*107.sv
echo "---- three-way score (cen107 --raw --tagblind; LHS is ALWAYS golden)"
for a in v1_shuf107 v2_hold107 v3_width107 v4_kind107 v5_dpth107 v6_alias107 v7_edge107; do
  for v in plain elab; do
    d="$OUT/${a}_${v}"
    G=$(find "$d/sl" -name '*.uhdm' 2>/dev/null | head -1)
    [ -n "${G:-}" ] && [ -f "$d/pris.uhdm" ] && [ -f "$d/patched.uhdm" ] || {
      echo "$a $v SKIP-NOFILE"; continue; }
    "${CEN_BIN:?set CEN_BIN}" "$G" "$d/pris.uhdm"    "$v" --raw --tagblind > "$d/raw.pris.txt"
    "${CEN_BIN}"             "$G" "$d/patched.uhdm" "$v" --raw --tagblind > "$d/raw.patch.txt"
    printf '%-14s %-6s ' "$a" "$v"
    python3 "$IMPL/score107.py" "$d/raw.pris.txt" "$d/raw.patch.txt" | tail -n 2 | head -n 1
  done
done
