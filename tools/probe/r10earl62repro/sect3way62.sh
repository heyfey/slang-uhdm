#!/usr/bin/env bash
# r10earl62 — THE ARBITER: the SECTIONED whole-dump path-normalised 3-way line
# multiset over golden / pristine / patched.
#
#   usage: sect3way61.sh <golden.dump> <pristine.dump> <patched.dump>
#
# WHY SECTIONED: `\_weaklyReferenced:` opens the TAIL, which r10earl60 proved
# `design::Compare` cannot reach (R8) -- counting it turns a cleared cell into a
# phantom mover and vice versa.  DEF+ELAB is everything the judge walks.
#
# WHY A MULTISET AND NOT A DIFF: `diff` reports a line that MOVED as one
# removal + one addition, so a cell that landed exactly ON golden's count reads
# as two movers.  The multiset counts per line and compares the three counts.
#
# WHY INDENTATION-STRIPPED: raw leading whitespace makes TREE DEPTH part of the
# key; boundary arms carry pre-existing depth differences vs golden and that is
# what made r10earl59's first verifier report a false AWAY-GOLDEN.
#
#   TO-GOLDEN    pristine count wrong -> patched count EQUALS golden's
#   AWAY-GOLDEN  pristine count RIGHT -> patched count WRONG   <== fatal
#   STILL-WRONG  both wrong, differently
set -u
G=${1:?golden dump}; P=${2:?pristine dump}; Q=${3:?patched dump}
for f in "$G" "$P" "$Q"; do [ -s "$f" ] || { echo "FATAL: missing/empty $f"; exit 9; }; done
T=$(mktemp -d)
norm() {
  awk '/^\\_weaklyReferenced:/{exit} {print}' "$1" \
    | sed -E 's#/[A-Za-z0-9_./+-]*/([A-Za-z0-9_.+-]+\.(sv|svh|vh|v))#\1#g' \
    | sed -E 's/^[[:space:]]+//' | LC_ALL=C sort | uniq -c \
    | awk '{c=$1; $1=""; sub(/^ /,""); print $0"\t"c}' | LC_ALL=C sort
}
norm "$G" > "$T/g"; norm "$P" > "$T/p"; norm "$Q" > "$T/q"
echo "DEF+ELAB distinct lines: golden=$(wc -l < "$T/g") pristine=$(wc -l < "$T/p") patched=$(wc -l < "$T/q")"
python3 - "$T/g" "$T/p" "$T/q" <<'PY'
import sys, collections
def load(p):
    d = {}
    for l in open(p, errors='replace'):
        k, _, c = l.rstrip('\n').rpartition('\t')
        d[k] = int(c)
    return d
g, p, q = (load(a) for a in sys.argv[1:4])
keys = set(g) | set(p) | set(q)
to = away = still = 0
rows = []
for k in keys:
    a, b, c = g.get(k, 0), p.get(k, 0), q.get(k, 0)
    if b == c:
        continue
    if b != a and c == a:   to += 1;    rows.append(('TO-GOLDEN', k, a, b, c))
    elif b == a and c != a: away += 1;  rows.append(('AWAY-GOLDEN', k, a, b, c))
    else:                   still += 1; rows.append(('STILL-WRONG', k, a, b, c))
print('TO-GOLDEN=%d  AWAY-GOLDEN=%d  STILL-WRONG=%d' % (to, away, still))
rows.sort(key=lambda r: (r[0] != 'AWAY-GOLDEN', r[0], -abs(r[4] - r[3])))
for r in rows[:60]:
    print('  %-12s golden=%-6d pristine=%-6d patched=%-6d  %s' % (r[0], r[2], r[3], r[4], r[1][:120]))
if away:
    print('FATAL: AWAY-GOLDEN is nonzero -- read every row above, do not summarise')
PY
rm -rf "$T"
