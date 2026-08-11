#!/bin/bash
# r10uvm48 — gates 3 and 4 back to back on ONE named binary, md5 printed BEFORE
# and AFTER each sweep (a pass was VOIDED for rebuilding mid-sweep and the taint
# was invisible because the tainted result agreed with the truth).
#   usage: gateall.sh <tag> <binary>
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE"/../../.. && pwd)
TAG=${1:?}
BIN=${2:?}
cd "$ROOT" || exit 1
[ -x "$BIN" ] || { echo "FATAL: no binary $BIN"; exit 3; }
echo "== u2r testflags: md5 BEFORE $(md5sum "$BIN")"
SLANG_UHDM=$BIN python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags \
  --out "/tmp/r10uvm48_u2r_$TAG.csv" --workdir "/tmp/r10uvm48_wdu2r_$TAG" --jobs 2 2>&1 | tail -8
echo "== u2r testflags: md5 AFTER  $(md5sum "$BIN")"
echo "== surelog both: md5 BEFORE $(md5sum "$BIN")"
SLANG_UHDM=$BIN python3 scripts/verify_golden.py --corpus surelog --mode both \
  --out "/tmp/r10uvm48_sl_$TAG.csv" --workdir "/tmp/r10uvm48_wdsl_$TAG" --jobs 2 2>&1 | tail -12
echo "== surelog both: md5 AFTER  $(md5sum "$BIN")"
