#!/usr/bin/env bash
# r10vbuvm31repro/vbound31.sh — run the boundary gate in ALL FOUR
# configurations (file/dir x def/elab) over a COPY of the probe tree.
# Delegates each cell to r10buvm31repro/bound31.sh (fd-3 arm list, children
# </dev/null, PROCESSED asserted, rc per cell, relative-path scratch keys).
#   vbound31.sh <bound31.sh> <pristine bin> <patched bin> <probe COPY> <out prefix>
set -u
B=${1:?bound31.sh}; P=${2:?pristine}; Q=${3:?patched}
export ROOT=${4:?probe copy}; PRE=${5:?out prefix}
export PRISTINE=$P PATCHED=$Q
for m in file dir; do
  for v in def elab; do
    MODE=$m VIEW=$v OUT="${PRE}_${m}_${v}" bash "$B" > "${PRE}_${m}_${v}.log" 2>&1
    echo "== MODE=$m VIEW=$v"; tail -20 "${PRE}_${m}_${v}.log"
  done
done
