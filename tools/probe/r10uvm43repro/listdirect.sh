#!/bin/bash
# r10uvm43 — LISTDIRECT: how many references reach a LISTING typespec object
# from a CONTAINER position (an array_typespec's Elem_typespec / Index_typespec,
# or the `STRING:associative` marker constant that carries an inner index).
# Golden's answer is NOT zero and that is the point: it is 20/12/12/12 on the
# UVM-4, because an ENUM, STRUCT or CLASS typedef's element/index DOES point at
# the listing object — only a VECTOR (bit/logic) typedef goes through a
# per-declaration named clone, which is exactly the restriction
# § arrayElemTdClone42 carries.  So the metric is "how far above golden", not
# "how far above zero": golden is 56 (20/12/12/12). CORRECTED AT PASS-43
# INTEGRATION — this header used to read "HEAD is 224 (+168), this pass 80
# (+24)", which is PASS 42's movement carried over STALE. At pass 43 HEAD and
# POST are BOTH 80: pass 43 is corpus-inert (953/953 byte-identical), so it
# made no LISTDIRECT movement at all. A future pass reading the old header
# would have credited pass 43 with a 224->80 drop it did not make. Re-measure,
# do not inherit a number.
# Run it on the r10uvm42tw census files res.sh already wrote.
#   usage: listdirect.sh <tag>          (tag as passed to res.sh)
set -u
ROOT=$(cd "$(dirname "$0")"/../../.. && pwd)
cd "$ROOT" || exit 1
TAG=${1:?}
tot=0
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  G=/tmp/r10uvm43_r10uvm42tw_g_$T.txt
  O=/tmp/r10uvm43_r10uvm42tw_${TAG}_$T.txt
  [ -s "$G" ] && [ -s "$O" ] || { echo "$T: census missing (run res.sh $TAG)"; continue; }
  cnt() { grep 'LISTED' "$1" | grep -oP '\| [0-9]+x(array_typespec|constant)\b' |
          awk -F'[ x]' '{s+=$2} END{print s+0}'; }
  g=$(cnt "$G"); o=$(cnt "$O")
  echo "$T golden=$g ours=$o"
  tot=$((tot + o))
done
echo "LISTDIRECT=$tot"
