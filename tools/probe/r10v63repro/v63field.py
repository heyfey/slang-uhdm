#!/usr/bin/env python3
# r10v63 — FIELD-LEVEL regression check.  For each Compare-visible field
# (kind, VpiDecompile, VpiSize, VpiConstType) independently: count cells where
# PRISTINE matched golden and PATCHED does not.  expr::Compare reads
# VpiDecompile FIRST, then VpiSize, then Typespec; constant::Compare adds
# VpiConstType last — so a decompile regression is the one that can DEEPEN a
# head.  MEASUREMENT ONLY.
import sys, collections
def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        t = ln.split()
        if not t or t[0] != 'PA': continue
        key = (t[1], t[2], t[3], t[4]); kind = t[5]
        f = {'kind': kind, 'dec': '-', 'sz': '-', 'ct': '-'}
        for x in t[6:]:
            if x.startswith('dec='): f['dec'] = x[4:]
            elif x.startswith('sz='): f['sz'] = x[3:]
            elif x.startswith('ct='): f['ct'] = x[3:]
        d[key].append((kind, f['dec'], f['sz'], f['ct']))
    for k in d: d[k].sort()
    return d
g, p, q = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
tag = sys.argv[4] if len(sys.argv) > 4 else '?'
names = ['kind', 'dec', 'sz', 'ct']
reg = collections.Counter(); fix = collections.Counter(); rows = []
for k in sorted(set(g) | set(p) | set(q)):
    gl, pl, ql = g.get(k, []), p.get(k, []), q.get(k, [])
    for i in range(max(len(gl), len(pl), len(ql))):
        gv = gl[i] if i < len(gl) else ('<a>',)*4
        pv = pl[i] if i < len(pl) else ('<a>',)*4
        qv = ql[i] if i < len(ql) else ('<a>',)*4
        for j, nm in enumerate(names):
            if pv[j] == gv[j] and qv[j] != gv[j]:
                reg[nm] += 1
                rows.append((nm, k, gv[j], pv[j], qv[j], gv, pv, qv))
            elif pv[j] != gv[j] and qv[j] == gv[j]:
                fix[nm] += 1
print(f"{tag} FIELD-REGRESSIONS " + " ".join(f"{n}={reg[n]}" for n in names) +
      "  | fixes " + " ".join(f"{n}={fix[n]}" for n in names))
for r in rows:
    print(f"  REG-{r[0]} {r[1][0]} {r[1][1]} {r[1][2]} {r[1][3]}  G={r[2]!r} P={r[3]!r} Q={r[4]!r}")
    print(f"        Gfull={r[5]}\n        Pfull={r[6]}\n        Qfull={r[7]}")
