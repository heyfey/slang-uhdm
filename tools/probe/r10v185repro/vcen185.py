#!/usr/bin/env python3
"""r10v185 VERIFIER census — golden vs ours over the `function` return-var face.

MEASUREMENT ONLY.  LHS is ALWAYS golden.  Multiset join on
(vpiFullName, function START line:col, hasStmt, parentKind:name); the row group
per key is SORTED and paired BY POSITION (a package's DEF and ELAB listings
carry the same method twice and a last-writer dict would drop one).

  usage: vcen185.py <golden.tsv> <ours.tsv> [label]

Prints, split by the PROTOTYPE (stmt=0) / DEFINITION (stmt=1) arm, the AGREE /
KIND-DIFF counts and every KIND-DIFF row.
"""
import sys, collections

def load(p):
    rows = collections.defaultdict(list)
    for line in open(p):
        t = line.rstrip('\n').split('\t')
        if len(t) != 9 or t[0] != 'FN':
            continue
        _, fn, span, stmt, par, rk, rspan, tsk, tsn = t
        rows[(fn, span.split('-')[0], stmt, par)].append((rk, rspan, tsk, tsn))
    for k in rows:
        rows[k].sort()
    return rows

def main():
    g, o = load(sys.argv[1]), load(sys.argv[2])
    label = sys.argv[3] if len(sys.argv) > 3 else ''
    c = collections.Counter()
    diffs = []
    for key in sorted(set(g) | set(o)):
        gv, ov = g.get(key, []), o.get(key, [])
        arm = 'PROTO' if key[2] == '0' else 'DEFN'
        for i in range(max(len(gv), len(ov))):
            a = gv[i][0] if i < len(gv) else None
            b = ov[i][0] if i < len(ov) else None
            if a is None:
                c[arm + '/O-ONLY'] += 1
            elif b is None:
                c[arm + '/G-ONLY'] += 1
            elif a == b:
                c[arm + '/AGREE'] += 1
            else:
                c[arm + '/KIND-DIFF'] += 1
                diffs.append('   %-5s %s %s  G=%s OURS=%s' %
                             (arm, key[0], key[1], a, b))
    print('%s  %s' % (label, ' '.join('%s=%d' % kv for kv in sorted(c.items()))))
    for d in diffs[:60]:
        print(d)

main()
