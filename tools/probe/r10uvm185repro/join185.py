#!/usr/bin/env python3
"""r10uvm185 — the MULTISET join of the `ct185cen` face, golden vs ours.

MEASUREMENT ONLY.  `uhdm-cmp` is the judge; this only reports.
LHS is ALWAYS golden, RHS is ALWAYS ours.

    usage: join185.py <cendir> [--all] [--kind-only]

Key = (vpiFullName, function span, hasStmt, parentKind:parentName).  Rows under
one key are a MULTISET (a package's DEF and ELAB listings carry the same
method), so the group is SORTED and paired BY POSITION — a last-writer dict
would silently drop rows (RESUME.md §9, census traps).  Keys present on one
side only are reported as their own buckets and never skipped.

Reported per row-mode and in total:
  KIND-DIFF   the compared field (`Return`'s VpiType) disagrees
  SPAN-DIFF   the kind agrees, the (uncompared) return-var span does not
  AGREE       both agree
  G-ONLY / O-ONLY  keys on one side only
The rows are also split by PROTO (hasStmt=0, parent is a class_defn) vs the
rest, because the decode says the prototype listing is the arm that moves.
"""
import sys, os, collections

def load(p):
    rows = collections.defaultdict(list)
    with open(p) as f:
        for line in f:
            t = line.rstrip('\n').split('\t')
            if len(t) != 9 or t[0] != 'FN':
                continue
            _, fn, span, stmt, par, rk, rspan, tsk, tsn = t
            # KEY ON THE FUNCTION'S START ONLY.  The END of a function object is
            # NOT a shared axis: golden ends a pure-virtual / prototype listing
            # at the method NAME token while we end it at the declaration, so an
            # end-keyed join manufactures G-ONLY/O-ONLY phantoms in pairs
            # (127+127 on BuildUVMPkg alone).  The START agrees on every object
            # of this face and is the axis the decode names.
            key = (fn, span.split('-')[0], stmt, par)
            rows[key].append((rk, rspan, tsk, tsn))
    for k in rows:
        rows[k].sort()
    return rows

def main():
    cendir = sys.argv[1]
    show_all = '--all' in sys.argv
    tot = collections.Counter()
    detail = []
    names = sorted({f.rsplit('.', 3)[0] + '.' + f.split('.')[-3]
                    for f in os.listdir(cendir) if f.endswith('.g.tsv')})
    for stem in names:
        g = load(os.path.join(cendir, stem + '.g.tsv'))
        o = load(os.path.join(cendir, stem + '.o.tsv'))
        c = collections.Counter()
        for key in set(g) | set(o):
            gv, ov = g.get(key, []), o.get(key, [])
            proto = key[2] == '0' and key[3].startswith('class_defn:')
            tag = 'PROTO' if proto else 'OTHER'
            n = max(len(gv), len(ov))
            for i in range(n):
                a = gv[i] if i < len(gv) else None
                b = ov[i] if i < len(ov) else None
                if a is None:
                    c[tag + '/O-ONLY'] += 1
                    detail.append((stem, tag, 'O-ONLY', key, None, b))
                elif b is None:
                    c[tag + '/G-ONLY'] += 1
                    detail.append((stem, tag, 'G-ONLY', key, a, None))
                elif a[0] != b[0]:
                    c[tag + '/KIND-DIFF'] += 1
                    detail.append((stem, tag, 'KIND-DIFF', key, a, b))
                elif a[1] != b[1]:
                    c[tag + '/SPAN-DIFF'] += 1
                    detail.append((stem, tag, 'SPAN-DIFF', key, a, b))
                else:
                    c[tag + '/AGREE'] += 1
        print('== %-26s %s' % (stem, ' '.join(
            '%s=%d' % (k, v) for k, v in sorted(c.items()))))
        tot.update(c)
    print('== TOTAL (nine UVM row-modes)')
    for k, v in sorted(tot.items()):
        print('   %-20s %d' % (k, v))
    print('-- detail rows (KIND-DIFF and G-ONLY/O-ONLY on the PROTO arm)')
    seen = collections.Counter()
    for stem, tag, verdict, key, a, b in detail:
        if not show_all and not (tag == 'PROTO' and verdict != 'SPAN-DIFF'):
            continue
        seen[(tag, verdict)] += 1
        print('   %-24s %-5s %-9s %s %s | L=%s R=%s' %
              (stem, tag, verdict, key[0], key[1], a, b))
    if not show_all:
        print('   (SPAN-DIFF rows suppressed; pass --all for every row)')

main()
