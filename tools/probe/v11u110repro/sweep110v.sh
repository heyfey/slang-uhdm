#!/bin/bash
# sweep110v.sh <tag> <frozen-binary> — u2r testflags + default, then surelog --mode both,
# --jobs 3, own workdir WD=${WD:-/tmp/v11u110_wd_<tag>} (four-char tags keep workdir names
# the same length for byteverify).  Run from a checkout of the base (REPO).
TAG=${1:?tag}; BIN=${2:?bin}
REPO=${REPO:-$(git -C "$(dirname "$0")" rev-parse --show-toplevel)}
WD=${WD:-/tmp/v11u110_wd_$TAG}
mkdir -p "$WD/u2r" "$WD/sl"
export SLANG_UHDM=$BIN; unset GOLDEN_DEFER
cd "$REPO" || exit 1
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags --jobs 3 --out "$WD/u2r_tf.csv" --workdir "$WD/u2r" > "$WD/u2r_tf.log" 2>&1
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode default --jobs 3 --out "$WD/u2r_def.csv" --workdir "$WD/u2r" > "$WD/u2r_def.log" 2>&1
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --out "$WD/sl.csv" --workdir "$WD/sl" > "$WD/sl.log" 2>&1
echo done > "$WD/DONE"
