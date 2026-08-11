#!/bin/bash
# r10uvm46 (cloned from pass 45) (cloned from pass 44) — regenerate an arm's golden with the git-repos Surelog binary, and
# emit our own database for the same source with a chosen slang binary.
#   usage: gold.sh <arm-dir-under-r10uvm44repro> <outdir> [slang-binary]
set -u
ARM=${1:?}
OUT=${2:?}
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE"/../../.. && pwd)
BIN=${3:-$ROOT/build/slang-uhdm}
SL=$HOME/git-repos/Surelog/build/bin/surelog
mkdir -p "$OUT" || exit 1
cd "$OUT" || exit 1
"$SL" -parse -d uhdm -nobuiltin "$HERE/$ARM/dut.sv" > "$OUT/surelog.log" 2>&1
echo "surelog rc=$?"
ls -la "$OUT/slpp_all/surelog.uhdm" 2>/dev/null
"$BIN" -nobuiltin "$HERE/$ARM/dut.sv" -o "$OUT/ours.uhdm" > "$OUT/slang.log" 2>&1
echo "slang rc=$?"
ls -la "$OUT/ours.uhdm" 2>/dev/null
