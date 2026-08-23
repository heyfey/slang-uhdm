#!/usr/bin/env python3
# r10uvm105repro/unsup105.py — the UNSUPPORTED-TYPESPEC half of the r10uvm105cen
# census, joined golden-vs-ours.  MEASUREMENT ONLY; the official uhdm-cmp is the
# judge.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   unsup105.py <golden.tsv> <ours.tsv> [--names N1,N2,...] [--rows]
#
# Key   = SITE, VIEW, OOB, CLS, OWNER, LC     (never the file: our expression
#         nodes carry an EMPTY VpiFile, buvm16's trap)
# Value = TSKIND, TSNAME, TSINSTANCE          (+ the declared name, for display
#         and for PAIRING only -- no join key here reads a NAME, because a key
#         that reads a name cannot see a rename)
#
# Both sides are MULTISETS per key (a declaration is listed 2-4 times: the DEF
# listing, the ELAB listing, one copy per importer/specialisation).  A positional
# join over those lists MANUFACTURES phantom MISS/EXTRA pairs whenever the two
# sides order the copies differently (RESUME §9, "NODEDUP censuses manufacture
# AWAY-GOLDEN phantoms"), so the difference below is a true multiset difference
# and the leftovers are paired by the DECLARED NAME.
#
# Classes reported, per (CLASS, SITE, OOB, VIEW):
#   AGREE  golden unsupported_typespec -> ours unsupported_typespec, SAME name
#          and SAME instance
#   KIND   golden unsupported_typespec -> ours a RESOLVED kind (the head's family)
#   NAME   both unsupported, names differ
#   INST   both unsupported, same name, different vpiInstance
#   MISS   golden unsupported, we emit NOTHING at that declaration
#   EXTRA  we mint an unsupported_typespec where golden resolves (or has nothing)
import sys, collections

def load(p):
    d = collections.defaultdict(collections.Counter)
    for ln in open(p):
        f = ln.rstrip('\n').split('\t')
        if len(f) < 12: continue
        d[tuple(f[1:7])][(f[8], f[9], f[10], f[7])] += 1
    return d

G = load(sys.argv[1]); O = load(sys.argv[2])
names = None; showrows = False
a = sys.argv[3:]
while a:
    if a[0] == '--names': names = set(a[1].split(',')); a = a[2:]
    elif a[0] == '--rows': showrows = True; a = a[1:]
    else: a = a[1:]

cnt = collections.Counter(); rows = []
UNS = 'unsupported_typespec'
for k in set(G) | set(O):
    gc = G.get(k, collections.Counter()); oc = O.get(k, collections.Counter())
    inter = gc & oc
    for v, n in inter.items():
        if v[0] != UNS: continue
        if names is not None and v[1] not in names: continue
        cnt[('AGREE', k[0], k[2], k[1])] += n
    gx = gc - inter; ox = oc - inter
    # pair the leftovers by the DECLARED NAME
    byname = collections.defaultdict(list)
    for v, n in ox.items():
        for _ in range(n): byname[v[3]].append(v)
    for v, n in gx.items():
        for _ in range(n):
            if v[0] != UNS:
                continue
            if names is not None and v[1] not in names:
                continue
            o = byname[v[3]].pop(0) if byname[v[3]] else None
            if o is None: cls = 'MISS'
            elif o[0] != UNS: cls = 'KIND'
            elif o[1] != v[1]: cls = 'NAME'
            elif o[2] != v[2]: cls = 'INST'
            else: cls = 'AGREE'
            cnt[(cls, k[0], k[2], k[1])] += 1
            if showrows and cls != 'AGREE':
                rows.append((cls, k, v, o))
    for nm, vs in byname.items():
        for o in vs:
            if o[0] != UNS: continue
            if names is not None and o[1] not in names: continue
            cnt[('EXTRA', k[0], k[2], k[1])] += 1
            if showrows: rows.append(('EXTRA', k, None, o))

for key in sorted(cnt, key=lambda x: (-cnt[x], x)):
    print("%-6s %-7s %-4s %-9s %d" % (key[0], key[1], key[2], key[3], cnt[key]))
if showrows:
    print("---- rows ----")
    for cls, k, g, o in sorted(rows, key=lambda r: (r[0], r[1])):
        print("%s\t%s\tG=%s\tO=%s" % (cls, '\t'.join(k),
              '|'.join(g) if g else '-', '|'.join(o) if o else '-'))
