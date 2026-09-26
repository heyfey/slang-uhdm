#!/bin/bash
# gridall.sh <binary> <tag> <case dir>... : grid.sh over cases, three at a time, sorted output.
b=$1; t=$2; shift 2
D=$(cd $(dirname $0) && pwd)
printf '%s\n' "$@" | xargs -P 3 -I{} $D/grid.sh {} $b $t "${ENVS[@]}" | sort
