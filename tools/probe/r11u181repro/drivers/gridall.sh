#!/bin/bash
# gridall.sh <binary> <tag> <casedir>... : grid.sh on every case, default and ELAB, 3 at a time.
# Extra env (switches) passes through the environment. Output sorted.
D=$(dirname $(realpath $0)); b=$1; t=$2; shift 2
for c in "$@"; do echo "$c"; done | xargs -P 3 -I{} bash -c "bash $D/grid.sh {} $b $t; ELAB=1 bash $D/grid.sh {} $b $t" | sort
