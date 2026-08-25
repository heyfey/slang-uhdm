#!/usr/bin/env bash
# r10uvm138 — ORDER-BLIND ATTRIBUTION of every byte mover.  Dumps are sorted
# and stripped of ids and of the workdir path before diffing, so the
# Scoreboard/default COIN (a ~50/50 vpiTaskFunc order flip) cannot be mistaken
# for a change and a change cannot hide behind it.  Every surviving line must
# belong to the law.
#   usage: attr138.sh <pristine-workdir> <patched-workdir> <rel> [<rel>...]
set -u
P=${1:?pris}; Q=${2:?pat}; shift 2
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
T=$(mktemp -d /tmp/r10uvm138_attr.XXXXXX)
for rel in "$@"; do
  [ -f "$P/$rel/slang.uhdm" ] && [ -f "$Q/$rel/slang.uhdm" ] || { echo "$rel SKIP-NOFILE"; continue; }
  for s in p q; do
    src=$P; [ $s = q ] && src=$Q
    "$DUMP" "$src/$rel/slang.uhdm" 2>/dev/null |
      sed 's#, id:[0-9]*##g; s#file:[^,]*,##g' | sort > "$T/$s.txt"
  done
  n=$(diff "$T/p.txt" "$T/q.txt" | grep -c '^[<>]'; true)
  cg=$(diff "$T/p.txt" "$T/q.txt" | grep -c '^>.*_constant: , line'; true)
  cr=$(diff "$T/p.txt" "$T/q.txt" | grep -c '^<.*_ref_obj: '; true)
  echo "$rel  orderblind_lines=$n  constants_added=$cg  ref_objs_removed=$cr"
  diff "$T/p.txt" "$T/q.txt" | grep -E '^[<>].*(_constant: , line|_ref_obj: )' | sed 's/^/    /'
done
rm -rf "$T"
