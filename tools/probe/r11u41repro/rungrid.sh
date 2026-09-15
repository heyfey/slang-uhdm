#!/bin/bash
# r11u41 — run one grid source through BOTH producers, recording rc for each arm.
# usage: rungrid.sh <src.sv> <tag> [extra slang args]
set -u
SRC=$(readlink -f "$1"); TAG=$2; shift 2
SL=${SLANG_UHDM:?export SLANG_UHDM explicitly}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
# The output root is OVERRIDABLE and never a shared path: this script must not
# be able to delete anyone else's scratch.
OUT=${OUT:-/tmp/r11u41_s}
D=$OUT/run_$TAG
case "$D" in /tmp/r11u41_s/run_*|*/run_*) ;; *) echo "refusing to clear $D"; exit 2;; esac
rm -rf "$D"; mkdir -p "$D"
cd "$D" || exit 1
"$SURELOG" -parse -nobuiltin -nocache -sv -d uhdm "$SRC" > surelog.log 2>&1
echo "RC surelog=$?"
"$SL" "$SRC" --single-unit -o ours.uhdm "$@" > slang.log 2>&1
echo "RC slang=$?"
grep -cE '^\[(ERR|FTL|SNT)' surelog.log; true
UD=$HOME/git-repos/UHDM/build/bin/uhdm-dump
"$UD" slpp_all/surelog.uhdm > g.raw 2>g.err; echo "RC dump-g=$?"
"$UD" ours.uhdm > o.raw 2>o.err; echo "RC dump-o=$?"
wc -l g.raw o.raw
echo "DIR=$D"
