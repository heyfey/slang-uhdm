#!/usr/bin/env python3
# v125 verifier scorer: multiset join of ARG cells on (callspan, idx), payload = kind|span|parent.
# LHS = golden.  SAME / MOVED-WRONG / ONLY-GOLDEN / ONLY-OURS.
import sys, collections
def load(p):
    d = collections.defaultdict(collections.Counter)
    for ln in open(p):
        if not ln.startswith('ARG'): continue
        f = ln.rstrip('\n').split('\t')
        call, idx, payload = f[1], f[2], f[3]
        cspan = call.split('|')[1]
        d[(cspan, idx)][payload] += 1
    return d
g, o = load(sys.argv[1]), load(sys.argv[2])
same = wrong = og = oo = 0
det = []
for k in sorted(set(g) | set(o)):
    gc, oc = g.get(k, collections.Counter()), o.get(k, collections.Counter())
    inter = gc & oc
    same += sum(inter.values())
    gr, orr = gc - inter, oc - inter
    n = min(sum(gr.values()), sum(orr.values()))
    wrong += n
    og += sum(gr.values()) - n
    oo += sum(orr.values()) - n
    if gr or orr:
        det.append((k, sorted(gr.elements()), sorted(orr.elements())))
print(f"SAME={same} MOVED-WRONG={wrong} ONLY-GOLDEN={og} ONLY-OURS={oo}")
for k, a, b in det:
    print(f"  CELL {k}\n    GOLD {a}\n    OURS {b}")
