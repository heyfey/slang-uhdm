#!/usr/bin/env bash
# r11v40 — the verifier's gate driver for ONE binary.  Every path is this
# pass's own and overridable; nothing here is shared with another pass.
#   usage: BIN=<binary> TAG=<tag> WD=<workdir-root> bash rungates40.sh
set -u
BIN=${BIN:?binary}
TAG=${TAG:?tag}
WD=${WD:-/tmp/v11u40_wd}
REPO=${REPO:-/home/heyfey/git-repos/slang-uhdm}
mkdir -p "$WD/u2r_$TAG" "$WD/sl_$TAG"
export SLANG_UHDM="$BIN"
unset GOLDEN_DEFER
cd "$REPO" || exit 2
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags --jobs 2 \
    --out "$WD/u2r_${TAG}_tf.csv" --workdir "$WD/u2r_$TAG" > "$WD/u2r_${TAG}_tf.log" 2>&1
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode default  --jobs 2 \
    --out "$WD/u2r_${TAG}_def.csv" --workdir "$WD/u2r_$TAG" > "$WD/u2r_${TAG}_def.log" 2>&1
echo "u2r done" > "$WD/u2r_$TAG.done"
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 2 \
    --out "$WD/sl_$TAG.csv" --workdir "$WD/sl_$TAG" > "$WD/sl_$TAG.log" 2>&1
echo "sl done" > "$WD/sl_$TAG.done"
