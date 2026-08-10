#!/bin/bash
# r10uvm41 — regenerate the t58a golden with the git-repos Surelog binary.
#   usage: gold58a.sh <arm-dir-under-r10uvm41repro> <outdir>
set -u
ARM=${1:-t58a}
OUT=${2:-/tmp/r10uvm41_g58a}
HERE=$(cd "$(dirname "$0")" && pwd)
SL=$HOME/git-repos/Surelog/build/bin/surelog
mkdir -p "$OUT"
cd "$OUT" || exit 1
"$SL" -parse -d uhdm -nobuiltin "$HERE/$ARM/dut.sv" > "$OUT/surelog.log" 2>&1
echo "rc=$?"
ls -la "$OUT/slpp_all/surelog.uhdm" 2>/dev/null
