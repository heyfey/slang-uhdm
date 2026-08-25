#!/usr/bin/env bash
# r10earl88 — run pareach88 over EVERY database of one sweep workdir (OURS) and
# its GOLDEN (from the test's own cmds.txt).  READS DATABASES, DISPATCHES NOTHING.
#   usage: PAREACH88=<bin> reach88.sh <sweep-workdir> <outfile-prefix>
set -u
P=${PAREACH88:?}
WD=$(readlink -f "$1"); OUT=$2
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
: > "$OUT.golden"; : > "$OUT.ours"
while IFS= read -r c; do
  d=$(dirname "$c"); key=${d#"$WD"/}; o="$d/slang.uhdm"
  g=$(sed -n 's/^surelog: (golden cache hit \(.*\))$/\1/p' "$c"); [ -n "$g" ] && g="$g/golden.uhdm"
  [ -f "$o" ] || continue
  [ -n "$g" ] && [ -f "$g" ] || continue
  "$P" "$g" 2>/dev/null | sed "s#^#$key|#" >> "$OUT.golden"
  "$P" "$o" 2>/dev/null | sed "s#^#$key|#" >> "$OUT.ours"
done 3< <(find "$WD" -name cmds.txt | sort) <&3
