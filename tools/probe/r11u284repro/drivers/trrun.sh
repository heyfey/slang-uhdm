#!/bin/bash
# r11u284 trrun.sh: decode aid (probe and fresh cases only): one run under R11U284_TRACE.
# trrun.sh <case dir> <binary> [extra args]: one run with R11U284_TRACE into a fresh dir; prints the trace; keeps o.uhdm at /tmp/r11u284_scratch/trrun/o.uhdm
[ -n "$FENCED" ] || { echo FENCED unset; exit 2; }
for n in $FENCED; do echo "$1" | grep -qw "$n" && { echo fenced; exit 2; }; done
R=/tmp/r11u284_scratch/trrun
rm -rf /tmp/r11u284_scratch/trrun
mkdir -p /tmp/r11u284_scratch/trrun/tr
cp "$1"/*.sv /tmp/r11u284_scratch/trrun/ 2>/dev/null
b=$2; shift 2
(cd /tmp/r11u284_scratch/trrun && R11U284_TRACE=/tmp/r11u284_scratch/trrun/tr R11U282_TRACE=/tmp/r11u284_scratch/trrun/tr "$b" dut.sv --single-unit --nobuiltin "$@" -o /tmp/r11u284_scratch/trrun/o.uhdm >/dev/null 2>&1)
cat /tmp/r11u284_scratch/trrun/tr/* 2>/dev/null | grep -v '^OUT'
