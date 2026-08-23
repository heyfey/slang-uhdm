#!/usr/bin/env python3
# r10earl76 — THE GOLDEN TABLE.  For one arm and one symbol NAME, print what
# golden / pristine / patched do at every (home, position) cell: `ref+ec` (a
# ref_obj bound to an enum_const), `ref` (an UNBOUND ref_obj), `const` (a fold),
# or `-` (no cell).  Reads three normalised cscen76 censuses.
#   usage: goldtbl76.py <g.n> <o.n> <q.n> <SymbolName>
import sys, re, collections
POS = ('for:i','for:c','for:n','for:b','whl:c','whl:b','dow:c','dow:b',
       'rpt:c','rpt:b','fe:b','fv:b','ev:ec','if:c','ie:c','cs:c','cs:ci')

def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        k, _, pay = ln.rstrip('\n').partition(' ')
        d[k].append(pay)
    return d

def cell(pays):
    if not pays: return '-'
    out = set()
    for p in pays:
        if p.startswith('kind=constant'): out.add('const')
        elif 'act=enum_const' in p: out.add('ref+ec')
        elif 'act=<null>' in p: out.add('ref')
        else: out.add('ref?')
    return '/'.join(sorted(out))

def home(k):
    m = re.search(r'gen_scope_array\(([^)]*)\)', k)
    if m: return 'gen:' + m.group(1)
    return 'modbody'

def pos(k):
    m = re.search(r'~(ST[^~]*)~', k)
    if not m: return '-'
    segs = [s.split('[')[0] for s in m.group(1).split('/')]
    for s in reversed(segs):
        if s in POS: return s
    return 'plain'

G, O, Q, NAME = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3]), sys.argv[4]
keys = [k for k in set(G) | set(O) | set(Q)
        if any(('name=%s ' % NAME) in p for p in G[k] + O[k] + Q[k])
        or any(re.search(r'~ELAB~', k) and False for p in [])]
rows = collections.defaultdict(dict)
for k in set(G) | set(O) | set(Q):
    ps = G[k] + O[k] + Q[k]
    if not any(('name=%s ' % NAME) in p for p in ps):
        # a FOLD carries no name; keep the key when the same (home,pos,span) has
        # a named cell on another side -- handled by the span join below
        pass
    rows[(home(k), pos(k), re.search(r'span=([^~ ]*)', k).group(1) if re.search(r'span=([^~ ]*)', k) else '?')][k] = (
        cell(G[k]), cell(O[k]), cell(Q[k]))
named = set()
for k in set(G) | set(O) | set(Q):
    if any(('name=%s ' % NAME) in p for p in G[k] + O[k] + Q[k]):
        named.add((home(k), pos(k),
                   re.search(r'span=([^~ ]*)', k).group(1) if re.search(r'span=([^~ ]*)', k) else '?'))
print('%-18s %-8s %-14s %-10s %-10s %-10s' % ('HOME', 'POS', 'SPAN', 'GOLDEN', 'PRISTINE', 'PATCHED'))
for key in sorted(rows):
    if key not in named: continue
    for k, (g, o, q) in sorted(rows[key].items()):
        print('%-18s %-8s %-14s %-10s %-10s %-10s' % (key[0], key[1], key[2], g, o, q))
