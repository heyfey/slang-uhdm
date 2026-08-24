#!/usr/bin/env python3
"""r10earl78 — 3-way scorer (golden / pristine / patched) over cacen78 rows,
JUDGE FIELDS ONLY.

earl65's lesson, restated: a scorer whose payload carries a field no generated
`Compare` reads manufactures verdicts.  `int_typespec::Compare`
(UHDM/build/generated/src/int_typespec.cpp:97) reads `Cast_to_expr`,
`VpiSigned` and `Ranges`, and through `typespec::Compare` the `VpiName`,
`Typedef_alias` and `Instance` — it NEVER reads `VpiValue`.  So the census
column `tsval=` (the multiconcat producer's `word size`) is DROPPED here.  It
is reported in README.md as a measured, judge-invisible difference this pass
does NOT touch, shared with the already-landed module-body twin.

Everything else in the payload IS read: `lhs=` (the cont_assign's Lhs kind and
VpiName), `rhs=` (the whole-Rhs shape), and on a constant `ct=` (VpiConstType),
`sz=` (VpiSize), `val=` (VpiValue), `dec=` (VpiDecompile), `ts=` (the typespec
KIND reached through the ref_typespec) and `tssgn=` (int_typespec VpiSigned).

  usage: score78.py <golden.ca> <pristine.ca> <patched.ca> <label>
"""
import sys, re, collections

SPANRE = re.compile(r'^[^ ]*?:(\d+:\d+-\d+:\d+)$')
DROP = re.compile(r' tsval=\S+')

def load(p):
    m = collections.defaultdict(list)
    for ln in open(p):
        if not ln.startswith('CA '):
            continue
        f = ln.rstrip('\n').split(' ')
        mm = SPANRE.match(f[4])
        sp = mm.group(1) if mm else f[4]
        m[(f[1], f[2], f[3], sp)].append(DROP.sub('', ' '.join(f[5:])))
    return m

def main():
    g, o, p = (load(x) for x in sys.argv[1:4])
    label = sys.argv[4] if len(sys.argv) > 4 else ''
    cnt = collections.Counter(); det = []
    for k in sorted(set(g) | set(o) | set(p)):
        gl, ol, pl = g.get(k, []), o.get(k, []), p.get(k, [])
        for i in range(max(len(gl), len(ol), len(pl))):
            gp = gl[i] if i < len(gl) else '<ABSENT>'
            op = ol[i] if i < len(ol) else '<ABSENT>'
            pp = pl[i] if i < len(pl) else '<ABSENT>'
            if op == pp:
                t = 'STILL-RIGHT' if gp == pp else 'STILL-WRONG'
            elif pp == gp:
                t = 'TO-GOLDEN'
            elif op == gp:
                t = 'AWAY-GOLDEN'
            else:
                t = 'MOVED-WRONG'
            cnt[t] += 1
            if t != 'STILL-RIGHT':
                det.append((t, k, gp, op, pp))
    print(f"{label} cells={sum(cnt.values())} " +
          ' '.join(f"{k}={v}" for k, v in sorted(cnt.items())))
    for t, k, gp, op, pp in det:
        if t in ('AWAY-GOLDEN', 'MOVED-WRONG'):
            print(f"  !! {t} {k}\n     G   {gp}\n     was {op}\n     now {pp}")
    for t, k, gp, op, pp in det:
        if t == 'STILL-WRONG':
            print(f"  .. STILL-WRONG {k}\n     G   {gp}\n     ours {pp}")

if __name__ == '__main__':
    main()
