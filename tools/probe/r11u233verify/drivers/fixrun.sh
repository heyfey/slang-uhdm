#!/bin/bash
# r11u233: fixrun.sh <tag> <binary> <casedir>... [-- ENV=VAL ...]: drivers/case.sh on every case in both views into the
# grid's case-view stores ($GW) under <tag> (the fix states beside the grid's law states); prints case.sh's lines.
source "$(dirname "$0")/env.sh" || exit 2
T=$1; B=$2; shift 2; [ -x "$B" ] || { echo "fixrun.sh: $B not executable" >&2; exit 2; }
C=(); while [ $# -gt 0 ] && [ "$1" != "--" ]; do C+=("$1"); shift; done; [ "$1" = "--" ] && shift
D=$(cd "$(dirname "$0")" && pwd)
for c in "${C[@]}"; do echo "$c 0"; echo "$c 1"; done | xargs -P ${P:-3} -L 1 bash -c 'EL=$1 bash '"$D"'/case.sh $0 '"$T $B $*"
