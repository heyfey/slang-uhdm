#!/bin/bash
# r10uvm48 — every t67 arm, one binary, one line each: the golden-vs-ours dump
# diff size.  LHS is ALWAYS golden(Surelog), RHS is ALWAYS ours.
#   usage: arms67.sh <tag> <binary>
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
TAG=${1:?}
BIN=${2:?}
for a in t67a t67b t67c t67d; do
  bash "$HERE/armdiff.sh" "$a" "/tmp/r10uvm48_${a}_${TAG}" "$BIN" 2> /dev/null | head -1
done
