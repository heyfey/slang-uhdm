#!/usr/bin/env python3
"""cenjoin13 — join two r10buvm13cen censuses as MULTISETS.

LHS is ALWAYS golden.  MEASUREMENT ONLY; uhdm-cmp is the judge.

buvm12's cenjoin lesson: keys COLLIDE (two formals of two identically named
functions in two views), and a last-writer-wins dict silently drops one row of
each colliding pair.  So every key maps to a LIST of values and the join walks
the two lists pairwise, reporting ARITY-DIFF when the lists differ in length.

Two row families are joined independently:
  DV   the default-value REF cells  -> key ... value = (act, akind, aname, atgt)
  IOV  the io_decl LISTING per task_func -> value = (n, names, dirs, ndef)
"""
import sys, collections

def load(path, want):
    d = collections.defaultdict(list)
    with open(path) as f:
        for ln in f:
            ln = ln.rstrip('\n')
            if not ln.startswith(want + ' '):
                continue
            # "<FAM> <tag> key=<key> f=v f=v ..."
            parts = ln.split(' ')
            rest = ' '.join(parts[2:])
            assert rest.startswith('key='), ln
            # key runs to the first ' <field>=' after it
            toks = rest.split(' ')
            key = toks[0][len('key='):]
            fields = {}
            for t in toks[1:]:
                if '=' in t:
                    k, v = t.split('=', 1)
                    fields[k] = v
            d[key].append(fields)
    return d

def strip_loc(d):
    """LOCATION-BLIND re-key: drop the trailing @line:col from the key and SORT
    each key's value list, so the io_decl-LOCATION family (which line:col a
    prototype's default expression is written at -- NOT a field Compare reads:
    BaseClass::Compare reads VpiType/VpiName/VpiDefName only) stops masking the
    BINDING family as ARITY-DIFF."""
    out = collections.defaultdict(list)
    for k, v in d.items():
        nk = k.rsplit('@', 1)[0]
        out[nk].extend(v)
    for k in out:
        out[k].sort(key=lambda f: (f.get('act', ''), f.get('akind', ''), f.get('aname', '')))
    return out

def join(g, p, cols, limit, label):
    cls = collections.Counter()
    ex = collections.defaultdict(list)
    for k in set(g) | set(p):
        gl, pl = g.get(k, []), p.get(k, [])
        if len(gl) != len(pl):
            cls['ARITY-DIFF'] += 1
            ex['ARITY-DIFF'].append('%s  G=%d P=%d' % (k, len(gl), len(pl)))
            continue
        if not pl:
            cls['G-only'] += len(gl); continue
        if not gl:
            cls['P-only'] += len(pl); continue
        for gf, pf in zip(gl, pl):
            gv = tuple(gf.get(c, '?') for c in cols)
            pv = tuple(pf.get(c, '?') for c in cols)
            if gv == pv:
                cls['AGREE'] += 1
            else:
                cls['DISAGREE'] += 1
                ex['DISAGREE'].append('%s\n     G %s\n     P %s\n     ctx %s' % (
                    k, ' '.join('%s=%s' % (c, v) for c, v in zip(cols, gv)),
                    ' '.join('%s=%s' % (c, v) for c, v in zip(cols, pv)),
                    ' '.join('%s=%s' % (c, gf.get(c, '-')) for c in
                             ('home', 'oob', 'meth', 'earlier', 'depth'))))
    print('== %s: ' % label + '  '.join('%s=%d' % kv for kv in sorted(cls.items())))
    for c in ('DISAGREE', 'ARITY-DIFF'):
        for e in ex[c][:limit]:
            print('   [%s] %s' % (c, e))
        if len(ex[c]) > limit:
            print('   [%s] ... %d more' % (c, len(ex[c]) - limit))
    return cls

if __name__ == '__main__':
    gp, pp = sys.argv[1], sys.argv[2]
    limit = int(sys.argv[3]) if len(sys.argv) > 3 else 30
    join(load(gp, 'IOV'), load(pp, 'IOV'), ('n', 'names', 'dirs', 'ndef'), limit, 'IOV listing')
    gd, pd = load(gp, 'DV'), load(pp, 'DV')
    join(gd, pd, ('act', 'akind', 'aname'), limit, 'DV default-value refs (location-keyed)')
    join(strip_loc(gd), strip_loc(pd), ('act', 'akind', 'aname'), limit,
         'DV default-value refs (LOCATION-BLIND)')
