#!/usr/bin/env bash
# r10buvm22repro/cen22.sh — the golden-vs-ours FUNCTION RETURN VARIABLE census
# over one pair of databases.  MEASUREMENT ONLY.
# LHS is ALWAYS golden; RHS is ALWAYS ours.
#   cen22.sh <golden.uhdm> <ours.uhdm> [<census binary>]
set -u
G=$1; O=$2; CEN=${3:-/tmp/r10buvm22_cen}
T=$(mktemp -d /tmp/r10buvm22_cen22.XXXXXX)
"$CEN" "$G" G > "$T/g.tsv" 2> "$T/g.err"; cat "$T/g.err"
"$CEN" "$O" O > "$T/o.tsv" 2> "$T/o.err"; cat "$T/o.err"
python3 - "$T/g.tsv" "$T/o.tsv" <<'PY'
import collections, sys
def load(p):
    d = collections.defaultdict(list)
    for l in open(p):
        f = l.rstrip('\n').split('\t')
        d[(f[1], f[2], f[3], f[4])].append(f)   # site, view, fullname, funcloc
    return d
G, O = load(sys.argv[1]), load(sys.argv[2])
gk, ok = set(G), set(O)
print('KEYS golden %d ours %d common %d golden-only %d ours-only %d'
      % (len(gk), len(ok), len(gk & ok), len(gk - ok), len(ok - gk)))
same = 0; diff = collections.Counter(); rows = []
for k in sorted(gk & ok):
    if len(G[k]) != len(O[k]):
        diff[('MULTIPLICITY', k[0], len(G[k]), len(O[k]))] += 1
        continue
    for a, b in zip(G[k], O[k]):
        if a[8] == b[8]:
            same += 1
        else:
            diff[(a[1], a[8], b[8], a[10])] += 1
            rows.append((k, a[8], b[8], a[10]))
print('KIND same', same, 'diff', sum(diff.values()))
for k, v in diff.most_common(60):
    print(' ', v, k)
for r in rows:
    print('  ROW', r)
PY
rm -rf "$T"
