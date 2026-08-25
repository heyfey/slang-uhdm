#!/usr/bin/env bash
# r10v138 — ORDER-BLIND attribution: sort + strip ids/paths, then print the
# WHOLE surviving diff (not a filtered view).
set -u
P=$1; Q=$2; shift 2
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
T=$(mktemp -d /tmp/v138_attr.XXXXXX)
for rel in "$@"; do
  for s in p q; do
    src=$P; [ $s = q ] && src=$Q
    "$DUMP" "$src/$rel/slang.uhdm" 2>/dev/null |
      sed 's#, id:[0-9]*##g; s#file:[^,]*,##g; s#/tmp/v138_wd_[a-z]*##g' | sort > "$T/$s.txt"
  done
  n=$(diff "$T/p.txt" "$T/q.txt" | grep -c '^[<>]'; true)
  echo "== $rel  orderblind_lines=$n"
  diff "$T/p.txt" "$T/q.txt" | grep '^[<>]' | sed 's/^/    /'
done
rm -rf "$T"
