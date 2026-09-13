#!/usr/bin/env bash
# Order-blind, path-normalised dump distance to golden, per grid arm, both binaries.
set -u
G=${G:-$(cd "$(dirname "$0")" && pwd)}
for d in "$@"; do
  dir=$G/$d
  [ -f "$dir/gold.dump" ] || { UD=$HOME/git-repos/UHDM/build/bin/uhdm-dump;
    g=$(find "$dir/gold" -name surelog.uhdm 2>/dev/null | head -1)
    [ -n "$g" ] && $UD "$g" > "$dir/gold.dump"
    [ -f "$dir/pris.uhdm" ] && $UD "$dir/pris.uhdm" > "$dir/pris.dump"
    [ -f "$dir/pat.uhdm" ] && $UD "$dir/pat.uhdm" > "$dir/pat.dump"; }
  norm() { sed -e "s#$dir/##g" -e 's#, id:[0-9]*##g' -e '1d' "$1" | sort; }
  norm "$dir/gold.dump" > "$dir/g.n"; norm "$dir/pris.dump" > "$dir/p.n"; norm "$dir/pat.dump" > "$dir/q.n"
  dp=$(diff "$dir/g.n" "$dir/p.n" | grep -c '^[<>]'; true)
  dq=$(diff "$dir/g.n" "$dir/q.n" | grep -c '^[<>]'; true)
  dir_v="NEUTRAL"; [ "$dq" -lt "$dp" ] && dir_v="TO-GOLDEN"; [ "$dq" -gt "$dp" ] && dir_v="AWAY-GOLDEN"
  echo "$d pris_dist=$dp pat_dist=$dq $dir_v"
done
