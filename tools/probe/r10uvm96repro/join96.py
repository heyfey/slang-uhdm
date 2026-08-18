#!/usr/bin/env python3
"""r10uvm96 — MEASUREMENT ONLY.  Multiset join of two ct96cen outputs.

Key   = the cast OPERATION's span (line:col-endline:endcol) + its OWNER's
        vpiFullName.  The FILE is NOT in the key: VpiFile is empty on most of
        our objects and the nearest file-bearing ancestor differs per side.
Judged= (typespec KIND, ref_typespec VpiName).  Neither the typespec's own
        span nor the source text is judged -- they are carried for reading.
A MULTISET join (Counter over (key,judged)) -- a dict would drop the duplicate
copies (DEF + ELAB + per-import clones) that every UVM database carries.
"""
import sys, collections

def load(p):
    rows = []
    for ln in open(p, encoding='utf-8', errors='replace'):
        f = ln.rstrip('\n').split('\t')
        if len(f) < 9:
            continue
        rows.append(f)
    return rows

def key(f):   return f[0] + '\t' + f[7]        # SPAN + OWNER (a vpiFullName)
def judged(f): return (f[1], f[4])

def main(g, o, tag):
    G, O = load(g), load(o)
    gk = collections.Counter((key(f), judged(f)) for f in G)
    ok = collections.Counter((key(f), judged(f)) for f in O)
    # reading columns, first seen
    info = {}
    for f in G + O:
        info.setdefault((key(f), judged(f)), f)
    same = 0
    diffs = collections.Counter()
    for kk in set(gk) | set(ok):
        n = min(gk[kk], ok[kk])
        same += n
    # per-key comparison of the judged multiset
    keys = set(k for k, _ in gk) | set(k for k, _ in ok)
    out = []
    for k in sorted(keys):
        gm = collections.Counter(j for (kk, j) in gk.elements() if kk == k) if False else None
    # rebuild per key
    gper = collections.defaultdict(collections.Counter)
    oper = collections.defaultdict(collections.Counter)
    for (k, j), n in gk.items(): gper[k][j] += n
    for (k, j), n in ok.items(): oper[k][j] += n
    agree = disagree = gonly = oonly = 0
    for k in sorted(keys):
        a, b = gper[k], oper[k]
        if a == b:
            agree += sum(a.values()); continue
        if not b: gonly += sum(a.values())
        elif not a: oonly += sum(b.values())
        else: disagree += 1
        gtxt = ' | '.join(f'{kk[0]}#{kk[1]}x{v}' for kk, v in sorted(a.items()))
        otxt = ' | '.join(f'{kk[0]}#{kk[1]}x{v}' for kk, v in sorted(b.items()))
        src = info.get((k, next(iter(a))) if a else (k, next(iter(b))))
        out.append(f'{tag}\tDIFF\t{k}\tG=[{gtxt}]\tO=[{otxt}]\tSRC={src[3] if src else "?"}')
    print(f'{tag}\tKEYS {len(keys)}\tAGREE_CELLS {agree}\tDIFF_KEYS {len(out)}\tG_ONLY_KEYS {sum(1 for k in keys if not oper[k])}\tO_ONLY_KEYS {sum(1 for k in keys if not gper[k])}')
    for l in out: print(l)

if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2], sys.argv[3] if len(sys.argv) > 3 else 'X')
