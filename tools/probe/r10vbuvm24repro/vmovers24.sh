#!/usr/bin/env bash
# r10vbuvm24repro/vmovers24.sh — score every MOVER against its OWN rebuilt
# golden with the verifier's view-general multiset comparator, and attribute
# the change with an ORDER-BLIND path-normalised uhdm-dump diff.
#   vmovers24.sh <pris sl wd> <pat sl wd> <cen bin> <out> <name...>
set -u
P=$1; Q=$2; CEN=$3; OUT=$4; shift 4
D=$(cd "$(dirname "$0")" && pwd)
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
mkdir -p "$OUT"
for n in "$@"; do
  for m in default testflags; do
    for d in "$P/$m/$n"-*/; do
      [ -d "$d" ] || continue
      qd="$Q/$m/$(basename "$d")"
      [ -f "$qd/slang.uhdm" ] || continue
      cmp -s "$d/slang.uhdm" "$qd/slang.uhdm" && { echo "== $m/$n BYTE-IDENTICAL"; continue; }
      G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)/golden.uhdm
      [ -f "$G" ] || { echo "SKIP-NOGOLD $m/$n"; continue; }
      "$CEN" "$G"             G > "$OUT/$m.$n.g.txt" 2>/dev/null
      "$CEN" "$d/slang.uhdm"  O > "$OUT/$m.$n.p.txt" 2>/dev/null
      "$CEN" "$qd/slang.uhdm" O > "$OUT/$m.$n.q.txt" 2>/dev/null
      echo "== $m/$n"
      python3 "$D/vgrid24.py" "$OUT/$m.$n.g.txt" "$OUT/$m.$n.p.txt" "$OUT/$m.$n.q.txt"
      # ORDER-BLIND attribution: sort both dumps, strip ids and the workdir.
      $DUMP "$d/slang.uhdm"  2>/dev/null | sed -E 's/, id:[0-9]+//g; s#/tmp/[^ ,]*##g' | sort > "$OUT/$m.$n.p.dump"
      $DUMP "$qd/slang.uhdm" 2>/dev/null | sed -E 's/, id:[0-9]+//g; s#/tmp/[^ ,]*##g' | sort > "$OUT/$m.$n.q.dump"
      echo "   order-blind dump diff lines: $(diff "$OUT/$m.$n.p.dump" "$OUT/$m.$n.q.dump" | grep -cE '^[<>]' || true)"
      diff "$OUT/$m.$n.p.dump" "$OUT/$m.$n.q.dump" | grep -E '^[<>]' \
        | sed -E 's/^(.) *//; s/:[0-9]+:[0-9]+.*//' | sort | uniq -c | sort -rn | head -20 | sed 's/^/   /'
    done
  done
done
