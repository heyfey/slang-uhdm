#!/usr/bin/env python3
"""r10earl80 — score g1_hops80.sv cell-by-cell, golden vs ours.

MEASUREMENT ONLY.  Keys are (elaborated instance chain, parameter name); the
payload carries ONLY judge-read constant fields (ct / size / value / decompile /
typespec kind) and NO span (earl60/earl65: a span-carrying payload hides flips).

usage: score80.py <golden.pa> <ours.pa> [<neutral-or-patched.pa>]
"""
import sys, collections, re

import os, importlib.util
_spec = importlib.util.spec_from_file_location(
    "gengrid80", os.path.join(os.path.dirname(os.path.abspath(__file__)),
                              "gengrid80.py"))
_g = importlib.util.module_from_spec(_spec)
_g.__name__ = "gengrid80"
_src = open(_spec.origin).read().replace("\nmain()", "\n")
exec(compile(_src, _spec.origin, "exec"), _g.__dict__)
SRC = _g.SRC
MID = [(m if m else "(untyped)") for m, _t in _g.MID]
NMID = len(MID)
HOMES = ["DECL", "OVR", "LP"]

def famof(k):           # k is 1-based, matches gengrid80's counter
    i = k - 1
    home = HOMES[i % 3]; i //= 3
    mid = MID[i % NMID];  i //= NMID
    return SRC[i], mid, home

def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        if not ln.startswith('PA '):
            continue
        f = ln.rstrip('\n').split(' ')
        chain, name = f[1], f[2]
        if 'module_inst(u_' not in chain:
            continue           # DEF listing / non-elaborated
        pay = ' '.join(x for x in f[3:] if not x.startswith('lsz='))
        d[(chain, name)].append(pay)
    for k in d: d[k].sort()
    return d

def hop(chain):
    return chain.count('/module_inst(u)')

def top(chain):
    m = re.search(r'module_inst\(u_(\d+)\)', chain)
    return int(m.group(1)) if m else 0

def dec(pay):
    m = re.search(r'dec=(\S+)', pay); return m.group(1) if m else '?'

def main():
    G, O = load(sys.argv[1]), load(sys.argv[2])
    P = load(sys.argv[3]) if len(sys.argv) > 3 else None
    ks = sorted(set(G) | set(O), key=lambda k: (top(k[0]), hop(k[0])))
    tot = diff = 0
    rows = []
    for k in ks:
        g, o = G.get(k, []), O.get(k, [])
        n = min(len(g), len(o))
        for i in range(n):
            tot += 1
            s, m, h = famof(top(k[0]))
            r = (s, m, h, hop(k[0]), k[1], g[i], o[i],
                 (P.get(k, [None]*(i+1))[i] if P else None))
            if g[i] != o[i]:
                diff += 1
            rows.append(r)
    print("CELLS=%d DIFFERING=%d  goldkeys=%d ourkeys=%d" % (tot, diff, len(G), len(O)))
    if P is not None:
        c = collections.Counter()
        for (s,m,h,hp,nm,gi,oi,pi) in rows:
            if pi is None: c['MISSING'] += 1
            elif gi == oi and gi == pi: c['STILL-RIGHT'] += 1
            elif pi == gi and oi != gi: c['AWAY-GOLDEN'] += 1
            elif pi != gi and oi == gi: c['TO-GOLDEN'] += 1
            elif pi == oi: c['STILL-WRONG'] += 1
            else: c['MOVED-WRONG'] += 1
        for k2 in ('STILL-RIGHT','TO-GOLDEN','AWAY-GOLDEN','MOVED-WRONG','STILL-WRONG','MISSING'):
            print("  %s: %d" % (k2, c[k2]))
    # DECOMPILE-WIDTH table: the written literal vs golden's decompile per hop
    print("\n== DECOMPILE by (source literal, mid type, home) x hop ==")
    tbl = {}
    for (s,m,h,hp,nm,gi,oi,pi) in rows:
        tbl.setdefault((s,m,h), {})[hp] = (dec(gi), dec(oi),
                                           dec(pi) if pi else '-')
    hdr = "%-7s %-13s %-5s | %-22s %-22s %-22s" % (
        "SRC","MID","HOME","hop0 A  G / O","hop1 B  G / O","hop2 D  G / O")
    print(hdr); print("-"*len(hdr))
    for (s,m,h) in sorted(tbl, key=lambda t:(SRC.index(t[0]),MID.index(t[1]),HOMES.index(t[2]))):
        c = tbl[(s,m,h)]
        cells = []
        for hp in (0,1,2):
            g,o,p = c.get(hp, ('-','-','-'))
            mark = ' ' if g==o else '*'
            cells.append("%s%-10s %-10s" % (mark, g, o))
        print("%-7s %-13s %-5s | %s %s %s" % (s,m,h,cells[0],cells[1],cells[2]))

main()
