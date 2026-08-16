#!/bin/bash
# vsd10: MULTISET DISTANCE golden-vs-ours per named row, for a verify_golden
# workdir.  The golden path is read out of the row's OWN cmds.txt (the cache
# directory turned into golden.uhdm), so this cannot compare the wrong golden.
set -u
WD=${1:?workdir}
MS=$(cd "$(dirname "$0")" && pwd)/msdist.sh
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
shift
for n in "$@"; do
  for mode in default testflags; do
    for d in "$WD/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      O=$d/slang.uhdm; C=$d/cmds.txt
      G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" 2>/dev/null | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
        printf '%-14s %-9s SKIP-NOFILE\n' "$n" "$mode"; continue
      fi
      "$DUMP" "$G" 2>/dev/null | sed 1d > /tmp/vsd10_ms_g.dump
      "$DUMP" "$O" 2>/dev/null | sed 1d > /tmp/vsd10_ms_o.dump
      v=$("$MS" /tmp/vsd10_ms_g.dump /tmp/vsd10_ms_o.dump | grep 'MULTISET' | grep -oE '[0-9]+$')
      printf '%-14s %-9s msdist=%-8s size=%s\n' "$n" "$mode" "$v" "$(stat -c%s "$O")"
    done
  done
done
