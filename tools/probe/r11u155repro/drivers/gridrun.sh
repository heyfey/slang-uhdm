#!/bin/bash
# gridrun.sh <binary> <tag> <dir>... [-- ENV=VAL ...]: grid.sh over every case of the named case dirs
B=$1; T=$2; shift 2; dirs=(); while [ $# -gt 0 ] && [ "$1" != "--" ]; do dirs+=("$1"); shift; done; [ "$1" = "--" ] && shift
D=$(dirname $(realpath $0))
for d in "${dirs[@]}"; do for c in $(ls -d /tmp/wt_r11u155/tools/probe/r11u155repro/cases/$d/*/ | sort); do $D/grid.sh $c $B $T "$@"; done; done
