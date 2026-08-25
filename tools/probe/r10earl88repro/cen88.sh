#!/usr/bin/env bash
# r10earl88 — run sig88 over EVERY database of one sweep workdir and its GOLDEN
# (read out of the test's OWN cmds.txt, so the golden cache entry is the one the
# harness used).  Writes one file per side.  READS DATABASES AND DISPATCHES
# NOTHING: no test — fenced or otherwise — is run by this script.
#   usage: SIG88=<bin> cen88.sh <sweep-workdir> <outfile-prefix>
set -u
SIG=${SIG88:?}
WD=$(readlink -f "$1"); OUT=$2
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
: > "$OUT.golden"; : > "$OUT.ours"; : > "$OUT.dbs"
n=0
while IFS= read -r c; do
  d=$(dirname "$c")
  key=${d#"$WD"/}
  o="$d/slang.uhdm"
  g=$(sed -n 's/^surelog: (golden cache hit \(.*\))$/\1/p' "$c")
  [ -n "$g" ] && g="$g/golden.uhdm"
  [ -f "$o" ] || continue
  [ -n "$g" ] && [ -f "$g" ] || continue
  n=$((n+1)); echo "$key" >> "$OUT.dbs"
  "$SIG" "$g" 2>/dev/null | sed "s#^#$key|#" >> "$OUT.golden"
  "$SIG" "$o" 2>/dev/null | sed "s#^#$key|#" >> "$OUT.ours"
done 3< <(find "$WD" -name cmds.txt | sort) <&3
echo "DBS=$n"
