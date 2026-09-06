#!/usr/bin/env bash
# r10uvm172repro/wide172.sh — the WIDE boundary gate: run bound172.sh over a
# COPY of the WHOLE committed probe tree, so no path filter can hide an arm and
# no arm is written to in place.  MEASUREMENT ONLY.
#   PRIS=.. PATCHED=.. wide172.sh <repo-root> <outdir>
set -u
ROOT=$(readlink -f "${1:?repo root}"); OUT=$(readlink -f "${2:?outdir}")
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
HERE=$(cd "$(dirname "$0")" && pwd)
rm -rf "$OUT/tree"; mkdir -p "$OUT/tree"
cp -r "$ROOT/tools/probe" "$OUT/tree/"
PRIS="$PRIS" PATCHED="$PATCHED" bash "$HERE/bound172.sh" "$OUT/tree" "$OUT/run"
