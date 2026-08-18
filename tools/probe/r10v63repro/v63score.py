#!/usr/bin/env python3
# r10v63 — 3-way MULTISET join of pacen63 censuses (golden / pristine / patched).
# Key = (sec, owner, line:col, paramname) — the Compare-visible SLOT; payload =
# (kind, ct, sz, dec)  [the fields constant::Compare reads; val printed for
# diagnosis].  Buckets each keyed cell TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG /
# STILL-RIGHT / STILL-WRONG.  MEASUREMENT ONLY.
import sys, collections
def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        t = ln.split()
        if not t or t[0] != 'PA': continue
        # PA sec owner L:C name kind ct= sz= val= dec= ov=
        key = (t[1], t[2], t[3], t[4])
        pay = tuple(t[5:])
        d[key].append(pay)
    for k in d: d[k].sort()
    return d
g, p, q = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
tag = sys.argv[4] if len(sys.argv) > 4 else '?'
def payfields(pay):
    # drop val= (not Compare-visible) and ov=
    return tuple(x for x in pay if not x.startswith('val=') and not x.startswith('ov='))
buckets = collections.Counter(); rows = []
for k in sorted(set(g) | set(p) | set(q)):
    gl, pl, ql = g.get(k, []), p.get(k, []), q.get(k, [])
    n = max(len(gl), len(pl), len(ql))
    for i in range(n):
        gv = payfields(gl[i]) if i < len(gl) else ('<absent>',)
        pv = payfields(pl[i]) if i < len(pl) else ('<absent>',)
        qv = payfields(ql[i]) if i < len(ql) else ('<absent>',)
        pr, qr = pv == gv, qv == gv
        if pr and qr: b = 'STILL-RIGHT'
        elif not pr and qr: b = 'TO-GOLDEN'
        elif pr and not qr: b = 'AWAY-GOLDEN'
        elif pv == qv: b = 'STILL-WRONG'
        else: b = 'MOVED-WRONG'
        buckets[b] += 1
        if b in ('AWAY-GOLDEN', 'TO-GOLDEN', 'MOVED-WRONG'):
            rows.append((b, k, gv, pv, qv))
tot = sum(buckets.values())
print(f"{tag} cells={tot} " + " ".join(f"{b}={buckets[b]}" for b in
      ('TO-GOLDEN','AWAY-GOLDEN','MOVED-WRONG','STILL-RIGHT','STILL-WRONG')))
for b, k, gv, pv, qv in rows:
    print(f"  {b} {k[0]} {k[1]} {k[2]} {k[3]}\n      G={gv}\n      P={pv}\n      Q={qv}")
