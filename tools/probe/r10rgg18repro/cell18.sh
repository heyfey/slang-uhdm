#!/usr/bin/env bash
# r10rgg18repro/cell18.sh — build ONE cell's golden (Surelog) and ours, dump
# both, and print the param_assign census of each.  MEASUREMENT ONLY.
#   usage: cell18.sh <cell-dir> <out-tag> [<binary>] [<extra surelog args>...]
# Surelog is invoked exactly as scripts/verify_golden.py's DEFAULT mode does
# (-parse -nobuiltin -nocache -sv <srcs> -mt 0 -mp 0 -o <work>), so a cell's
# golden is the same object the corpus sweeps compare against.
set -u
D=$(cd "$1" && pwd); TAG=$2; BIN=${3:-/tmp/r10rgg18_bin/slang-uhdm-base}; shift 3 || shift 2
W=/tmp/r10rgg18_cell_$TAG
rm -rf "$W"; mkdir -p "$W"
mapfile -t SRCS < <(cd "$D" && ls *.sv *.v 2>/dev/null)
( cd "$D" && ~/git-repos/Surelog/build/bin/surelog -parse -nobuiltin -nocache -sv \
     "$@" "${SRCS[@]}" -mt 0 -mp 0 -o "$W" > "$W/surelog.log" 2>&1 )
echo "surelog rc=$? -> $(ls $W/slpp_all/*.uhdm $W/slpp_unit/*.uhdm 2>/dev/null | head -1)"
G=$(ls "$W"/slpp_all/*.uhdm "$W"/slpp_unit/*.uhdm 2>/dev/null | head -1)
( cd "$D" && "$BIN" "${SRCS[@]}" -o "$W/ours.uhdm" > "$W/slang.log" 2>&1 )
echo "slang rc=$? bin=$BIN"
[ -n "${G:-}" ] && ~/.local/bin/uhdm-dump "$G" > "$W/golden.dump" 2>&1
[ -f "$W/ours.uhdm" ] && ~/.local/bin/uhdm-dump "$W/ours.uhdm" > "$W/ours.dump" 2>&1
[ -n "${G:-}" ] && /tmp/r10rgg18_pacensus "$G" G > "$W/golden.cen" 2>"$W/golden.cen.err"
[ -f "$W/ours.uhdm" ] && /tmp/r10rgg18_pacensus "$W/ours.uhdm" O > "$W/ours.cen" 2>"$W/ours.cen.err"
echo "work=$W golden=$G"
