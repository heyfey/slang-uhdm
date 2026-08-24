#!/usr/bin/env bash
# r10buvm33repro/coin33.sh — the NONDETERMINISM CONTROL for a boundary mover.
# Runs the SAME binary TWICE on one directory arm and diffs the dumps: a
# non-zero raw diff with a ZERO order-blind (sorted) diff proves the arm is a
# COIN (RESUME §9: the vpiTaskFunc list ORDER flips per invocation under
# slang's parallel parse), not a mover this pass caused.
#   coin33.sh <arm dir> <binary> <workdir> [--elabuhdm]
set -u
D=$1; BIN=$2; W=$3; shift 3; EF=${1:-}
mkdir -p "$W"; srcs=$(ls "$D"/*.sv "$D"/*.v 2>/dev/null | LC_ALL=C sort)
( cd "$W" && "$BIN" $srcs $EF -o r1.uhdm >/dev/null 2>&1 </dev/null
             "$BIN" $srcs $EF -o r2.uhdm >/dev/null 2>&1 </dev/null
             uhdm-dump r1.uhdm 2>&1 | tail -n +2 > r1.txt
             uhdm-dump r2.uhdm 2>&1 | tail -n +2 > r2.txt )
raw=$(diff "$W/r1.txt" "$W/r2.txt" | grep -c '^[<>]' || true)
ob=$(diff <(LC_ALL=C sort "$W/r1.txt") <(LC_ALL=C sort "$W/r2.txt") | grep -c '^[<>]' || true)
echo "$D  same-binary-twice: raw=$raw order-blind=$ob"
