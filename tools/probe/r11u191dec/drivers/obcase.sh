#!/bin/bash
# r11u191: the ORDER-BLIND uhdm-dump distance golden vs ours (sorted dumps, paths stripped, the one `Restored design`
# header pair excluded) of the case dirs given, per binary of $OBBINS; reads the grid's run dirs (grid.sh first).
# usage: obcase.sh <case rel path>...
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
for r in "$@"; do line="$r"
  for b in ${OBBINS:-slang-uhdm slang-uhdm.law}; do d=/tmp/r11u191_grid/$b/$r
    n=$(diff <(grep -v 'Restored design' $d/g.dump | sed 's#/tmp/[^ ]*/##g' | sort) <(grep -v 'Restored design' $d/o.dump | sed 's#/tmp/[^ ]*/##g' | sort) | grep -c '^[<>]')
    line="$line	$b:$n"; done; echo "$line"; done
