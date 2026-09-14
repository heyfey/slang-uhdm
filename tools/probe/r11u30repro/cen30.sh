#!/usr/bin/env bash
# r11u30 — MEASUREMENT ONLY.  The corpus INSIDE/LIST-OP census for one named
# row, three ways: golden (LHS, always) / pristine / patched, keyed by the
# committed r10uvm99 reader (`opcen99.py`: SITE + nearest named ancestor + span
# -> operand shapes).  Scored MULTISET and SET, exactly as r10uvm99 scored it.
#
#   usage: PRISWD=<pristine workdir> PATWD=<patched workdir> ./cen30.sh <mode> <name>
#
# GUARDS: the golden path is read from the row's OWN cmds.txt (never guessed);
# a missing database on either side prints NOFILE and is counted, so a driver
# that reaches nothing cannot read as perfection.
set -u
MODE=${1:?mode}; NAME=${2:?name}
HERE=$(cd "$(dirname "$0")" && pwd)
OPCEN=$HERE/../r10uvm99repro/opcen99.py
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
PRISWD=${PRISWD:?}; PATWD=${PATWD:?}
O=${CENOUT:-/tmp/r11u30_cen}/$MODE-$NAME; mkdir -p "$O"
pd=$(find "$PRISWD/$MODE" -maxdepth 1 -type d -name "$NAME-*" | head -1)
qd=$(find "$PATWD/$MODE"  -maxdepth 1 -type d -name "$NAME-*" | head -1)
[ -n "$pd" ] && [ -n "$qd" ] || { echo "$MODE/$NAME NOFILE-DIR"; exit 5; }
g=$(grep -o '/[^ )]*slang-uhdm-goldens/[0-9a-f]*' "$pd/cmds.txt" | head -1)/golden.uhdm
for f in "$g" "$pd/slang.uhdm" "$qd/slang.uhdm"; do
  [ -f "$f" ] || { echo "$MODE/$NAME NOFILE $f"; exit 5; }
done
"$DUMP" "$g"             > "$O/g.dump"    2>/dev/null
"$DUMP" "$pd/slang.uhdm" > "$O/pris.dump" 2>/dev/null
"$DUMP" "$qd/slang.uhdm" > "$O/pat.dump"  2>/dev/null
for t in g pris pat; do python3 "$OPCEN" "$O/$t.dump" > "$O/$t.cen"; done
python3 - "$MODE/$NAME" "$O" <<'PY'
import sys, collections
key, O = sys.argv[1], sys.argv[2]
def load(p):
    d = collections.defaultdict(list)
    for l in open(p):
        c = l.rstrip('\n').split('\t')
        if len(c) == 3: d[(c[0], c[1])].append(c[2])
    return d
G, P, Q = load(O+'/g.cen'), load(O+'/pris.cen'), load(O+'/pat.cen')
for scoring in ('MULTISET', 'SET'):
    norm = (lambda x: sorted(x)) if scoring == 'MULTISET' else (lambda x: sorted(set(x)))
    tot = collections.Counter(); lines = []
    for k in sorted(set(G) | set(P) | set(Q)):
        g, p, q = norm(G.get(k, [])), norm(P.get(k, [])), norm(Q.get(k, []))
        v = ('ALREADY-OK' if p == g and q == g else
             'TO-GOLDEN'  if p != g and q == g else
             'AWAY-GOLDEN' if p == g and q != g else 'STILL')
        tot[v] += 1
        if v in ('AWAY-GOLDEN', 'TO-GOLDEN'):
            lines.append('   %-11s %s\n       G=%s\n       P=%s\n       Q=%s' % (v, k, g, p, q))
    print('%-34s [%-8s] cells %4d  ALREADY-OK %4d  TO-GOLDEN %3d  AWAY-GOLDEN %3d  STILL %3d' % (
        key, scoring, sum(tot.values()), tot['ALREADY-OK'], tot['TO-GOLDEN'],
        tot['AWAY-GOLDEN'], tot['STILL']))
    if scoring == 'SET':
        for l in lines: print(l)
PY
