#!/usr/bin/env python3
"""r10earl80 — print the FULL judge-visible payload (ct / size / value /
decompile) of each g<N> chain cell, golden vs ours, per hop.  MEASUREMENT ONLY.
usage: GRID80=g2 val80.py <golden.pa> <ours.pa> [<patched.pa>]"""
import sys, os, importlib.util, collections, re
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
_s = importlib.util.spec_from_file_location("gengrid80",
      os.path.join(os.path.dirname(os.path.abspath(__file__)), "gengrid80.py"))
_g = importlib.util.module_from_spec(_s)
exec(compile(open(_s.origin).read().replace("\nmain()", "\n"), _s.origin, "exec"),
     _g.__dict__)
SRC = _g.SRC; MID = [(m if m else "(untyped)") for m, _t in _g.MID]
NMID = len(MID); HOMES = ["DECL", "OVR", "LP"]
def famof(k):
    i = k - 1; h = HOMES[i % 3]; i //= 3; m = MID[i % NMID]; i //= NMID
    return SRC[i], m, h
def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        if not ln.startswith('PA '): continue
        f = ln.rstrip('\n').split(' ')
        if 'module_inst(u_' not in f[1]: continue
        d[(f[1], f[2])].append(' '.join(x for x in f[3:] if not x.startswith('lsz=')))
    for k in d: d[k].sort()
    return d
def hop(c): return c.count('/module_inst(u)')
def topi(c):
    m = re.search(r'module_inst\(u_(\d+)\)', c); return int(m.group(1)) if m else 0
def pay(s):
    d = dict(x.split('=',1) for x in s.split() if '=' in x)
    return "ct%s/%s/%s/%s" % (d.get('ct','-'), d.get('sz','-'),
                              d.get('val','-'), d.get('dec','-'))
def main():
    G, O = load(sys.argv[1]), load(sys.argv[2])
    P = load(sys.argv[3]) if len(sys.argv) > 3 else None
    tbl = {}
    for k in set(G) | set(O):
        g, o = G.get(k, []), O.get(k, [])
        for i in range(min(len(g), len(o))):
            s, m, h = famof(topi(k[0]))
            tbl.setdefault((s, m, h), {})[hop(k[0])] = (
                pay(g[i]), pay(o[i]),
                pay(P[k][i]) if P and k in P and i < len(P[k]) else '-')
    n = bad = 0
    for key in sorted(tbl, key=lambda t: (SRC.index(t[0]), MID.index(t[1]),
                                          HOMES.index(t[2]))):
        c = tbl[key]
        line = "%-12s %-18s %-5s |" % key
        flag = ""
        for hp in (0, 1, 2):
            g, o, p = c.get(hp, ('-', '-', '-'))
            n += 1
            mark = ' ' if g == o else '*'
            if g != o: bad += 1; flag = "*"
            line += " %s%-26s %-26s |" % (mark, g, o)
        print(line)
    print("CELLS=%d DIFFERING=%d" % (n, bad))
main()
