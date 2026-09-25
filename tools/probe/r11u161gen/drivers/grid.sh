#!/bin/bash
# grid.sh <tag> <binary> <casedir-root>... [-- ENV=VAL ...]: case.sh on every dut.sv below the roots (sub-dirs
# included), file list read on fd 3, asserts PROCESSED == LISTED.  EL=1 in the environment for the elab view.
[ -n "$FENCED" ] || { echo "grid.sh: source drivers/env.sh" >&2; exit 2; }
D=$(cd "$(dirname "$0")" && pwd); t=$1; b=$2; shift 2; roots=(); while [ $# -gt 0 ] && [ "$1" != "--" ]; do roots+=("$1"); shift; done; [ "${1:-}" = "--" ] && shift
L=$(mktemp /tmp/r11u161_scratch/gridlist.XXXX); find "${roots[@]}" -name dut.sv | sort | xargs -n1 dirname > $L
n=0; while read -u 3 c; do bash $D/case.sh $c $t $b "$@" < /dev/null; n=$((n+1)); done 3< $L
echo "PROCESSED $n LISTED $(wc -l < $L)"; rm -f $L
