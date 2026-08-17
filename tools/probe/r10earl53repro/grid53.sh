#!/usr/bin/env bash
# r10earl53 — the ARM GRID: golden vs pristine vs patched, one line per
# hier_path PRINT, keyed {enclosing instance, enclosing port, path, span,
# field}.  LHS is ALWAYS golden.
#
#   usage: grid53.sh <arm-name>          e.g. grid53.sh a1
#          (reads /tmp/r10earl53_arm_<n>/{g,o}.dump and
#                 /tmp/r10earl53_arm_<n>p/o.dump)
#
# GUARD: a missing dump is FATAL, never an empty (green-looking) table.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
N=${1:?arm name}
G=/tmp/r10earl53_arm_$N/g.dump
P=/tmp/r10earl53_arm_$N/o.dump
Q=/tmp/r10earl53_arm_${N}p/o.dump
for f in "$G" "$P" "$Q"; do
  [ -s "$f" ] || { echo "FATAL: missing/empty $f"; exit 3; }
done
t=$(mktemp -d)
for k in g p q; do
  case $k in g) f=$G;; p) f=$P;; q) f=$Q;; esac
  python3 "$HERE/hpcensus53.py" "$f" --key 2>/dev/null | grep -P '\t' \
    | awk -F'\t' '{printf "%s|%s|%s|%s|%s\t%s %s\n",$1,$2,$3,$4,$5,$6,$7}' \
    | LC_ALL=C sort > "$t/$k"
done
echo "KEY = instance|port|path|span|field      (g=golden p=pristine q=patched)"
LC_ALL=C join -t$'\t' -a1 -a2 -e MISSING -o 0,1.2,2.2 "$t/g" "$t/p" \
  | LC_ALL=C sort > "$t/gp"
LC_ALL=C join -t$'\t' -a1 -a2 -e MISSING -o 0,1.2,1.3,2.2 "$t/gp" "$t/q" \
  | awk -F'\t' '{printf "%-70s  g=%-34s p=%-34s q=%s\n",$1,$2,$3,$4}'
rm -rf "$t"
