#!/usr/bin/env bash
# r10uvm99 — MEASUREMENT ONLY.  The corpus INSIDE/LIST-OP census, three-way:
# golden(LHS) / pristine / patched, over one (mode, test) of a verify_golden
# sweep.  Golden is read from the test's OWN cmds.txt, never guessed.
#   ./cen99.sh <rel/dir> <patched wd> <pristine wd> [outdir]
set -u
REL=${1:?rel}; A=${2:?patched wd}; B=${3:?pristine wd}; OUT=${4:-/tmp/r10uvm99_cen}
HERE=$(cd "$(dirname "$0")" && pwd)
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
mkdir -p "$OUT" || exit 9
key=$(echo "$REL" | sed 's#[^A-Za-z0-9._-]#_#g')
g=$(sed -n 's/.*golden cache hit \(.*\))/\1/p' "$B/$REL/cmds.txt" | head -1)
[ -n "$g" ] && g="$g/golden.uhdm"
[ -f "$g" ] || { echo "$REL NO_GOLDEN"; exit 5; }
for t in g pris pat; do
  case $t in g) db=$g;; pris) db=$B/$REL/slang.uhdm;; pat) db=$A/$REL/slang.uhdm;; esac
  [ -f "$db" ] || { echo "$REL NO_DB($t)"; exit 5; }
  "$DUMP" "$db" 2>/dev/null </dev/null > "$OUT/$key.$t.dump"
  python3 "$HERE/opcen99.py" "$OUT/$key.$t.dump" > "$OUT/$key.$t.cen"
  rm -f "$OUT/$key.$t.dump"
done
python3 - "$REL" "$OUT/$key" <<'PY'
import sys, collections
rel, base = sys.argv[1], sys.argv[2]
def load(p):
    d = collections.defaultdict(list)
    for l in open(p):
        c = l.rstrip('\n').split('\t')
        if len(c) == 3: d[(c[0], c[1])].append(c[2])
    return d
G, P, Q = load(base+'.g.cen'), load(base+'.pris.cen'), load(base+'.pat.cen')
for scoring in ('MULTISET', 'SET'):
    norm = (lambda x: sorted(x)) if scoring == 'MULTISET' else (lambda x: sorted(set(x)))
    t = collections.Counter(); shown = []
    for k in sorted(set(G) | set(P) | set(Q)):
        g, p, q = norm(G.get(k, [])), norm(P.get(k, [])), norm(Q.get(k, []))
        if p == g and q == g: v = 'ALREADY-OK'
        elif p != g and q == g: v = 'TO-GOLDEN'
        elif p == g and q != g: v = 'AWAY-GOLDEN'
        else: v = 'STILL'
        t[v] += 1
        if v in ('TO-GOLDEN', 'AWAY-GOLDEN'):
            shown.append('    %-11s %s\n        G=%s\n        P=%s\n        Q=%s' % (v, k, g, p, q))
    print('  %-34s [%-8s] cells %5d  ALREADY-OK %5d  TO-GOLDEN %3d  AWAY-GOLDEN %3d  STILL %4d' % (
        rel, scoring, sum(t.values()), t['ALREADY-OK'], t['TO-GOLDEN'], t['AWAY-GOLDEN'], t['STILL']))
    if scoring == 'SET':
        for s in shown: print(s)
PY
