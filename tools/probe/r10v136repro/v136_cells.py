#!/usr/bin/env python3
import sys, os, subprocess, collections
from importlib.machinery import SourceFileLoader
cen = SourceFileLoader("cen", os.path.join(os.path.dirname(os.path.abspath(__file__)), "v136_cen.py")).load_module()
BUILTIN = ('work@mailbox','work@process','work@semaphore')
def load(p):
    c = cen.cells(p)
    d = collections.defaultdict(collections.Counter)
    for (fn, kind), n in c.items():
        if fn.startswith(BUILTIN): continue
        d[fn][kind] += n
    return d
root = sys.argv[1]
tot = collections.Counter()
for arm in sorted(os.listdir(root)):
    D = os.path.join(root, arm)
    for view, (g,o,q) in (("DEF",("g","o","q")), ("ELAB",("ge","oe","qe"))):
        ps = [os.path.join(D, f+".uhdm") for f in (g,o,q)]
        if not all(os.path.exists(p) for p in ps): continue
        G, O, Q = (load(p) for p in ps)
        keys = set(G)|set(O)|set(Q)
        for k in sorted(keys):
            g_, o_, q_ = G.get(k), O.get(k), Q.get(k)
            if k not in G:
                tot["ONLY-OURS"] += 1
                if o_ != q_: print(f"{arm} {view} ONLY-OURS-CHANGED {k}: {dict(o_)} -> {dict(q_)}")
                continue
            if k not in O and k not in Q:
                tot["ONLY-GOLDEN"] += 1; continue
            ok_o, ok_q = (o_ == g_), (q_ == g_)
            if ok_o and ok_q: tot["AGREE"] += 1
            elif not ok_o and ok_q: tot["FIXED"] += 1; print(f"{arm} {view} FIXED {k}: {dict(o_)} -> {dict(q_)} (G {dict(g_)})")
            elif ok_o and not ok_q: tot["MOVED-WRONG"] += 1; print(f"{arm} {view} !!MOVED-WRONG {k}: {dict(o_)} -> {dict(q_)} (G {dict(g_)})")
            else:
                if o_ != q_: tot["CHANGED-STILL-WRONG"] += 1; print(f"{arm} {view} CHANGED-STILL-WRONG {k}: {dict(o_)} -> {dict(q_)} (G {dict(g_)})")
                else: tot["STILL-WRONG"] += 1
print("TOTALS", dict(tot))
