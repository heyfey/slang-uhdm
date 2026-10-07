#!/bin/bash
# v11u275: run grid.sh over case dirs in parallel shards; $1 = out prefix, rest = case dirs
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export B=${B:?export B} S=${S:?export S}
D=$(cd "$(dirname "$0")" && pwd)
pre=$1; shift
n=0; for c in "$@"; do echo "$c" > /dev/null; done
printf '%s\n' "$@" | awk -v P=$pre '{print > (P ".list" (NR%4))}'
for k in 0 1 2 3; do [ -s $pre.list$k ] && bash $D/${GRID:-grid.sh} $pre.part$k $(cat $pre.list$k) & done; wait
cat $pre.part? > $pre.txt
