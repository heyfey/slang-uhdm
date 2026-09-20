#!/usr/bin/env python3
"""v11u66 VERIFIER LOC-KEYED SCORER — aligns operands by their own SOURCE
RANGE, not by ordinal, because our walk emits a different NUMBER of operands
than golden on several committed arms (e2_width56 drops the `'x`/`'z`
setters), and an ordinal key silently compares the wrong pair.

For every param_assign whose Rhs is an operation, in every listing, every
operand that is a `constant` is keyed by
  (section, Lhs name, operand source range)
and carries the JUDGE's own fields: vpiConstType, vpiSize, vpiDecompile
(generated `constant::Compare` + `expr::Compare` read exactly these, plus the
typespec; `VpiValue` is NOT read).  Multiset per key.

usage: loc66v.py <g.dump> <pris.dump> <law.dump> <arm>
"""
import re, sys, collections

def ind(l): return len(l) - len(l.lstrip())

def block(lines, i, base):
    out = []
    while i < len(lines):
        l = lines[i]
        if l.strip() and ind(l) <= base: break
        out.append(l); i += 1
    return out, i

def payload(blk, base):
    sz = ct = dec = '?'
    for l in blk:
        if ind(l) != base + 2: continue
        s = l.lstrip()
        if s.startswith('|vpiSize:'): sz = s.split(':', 1)[1].strip()
        elif s.startswith('|vpiConstType:'): ct = s.split(':', 1)[1].strip()
        elif s.startswith('|vpiDecompile:'): dec = s.split(':', 1)[1].strip()
    return (ct, sz, dec)

def parse(path):
    lines = open(path, errors='replace').read().splitlines()
    out = collections.defaultdict(collections.Counter)
    sect = '?'
    i = 0
    while i < len(lines):
        ln = lines[i]
        m = re.match(r'^\|(uhdm\w+):', ln)
        if m: sect = m.group(1); i += 1; continue
        m = re.match(r'^(\s*)\\_param_assign: ', ln)
        if not m: i += 1; continue
        pind = ind(ln)
        blk, i = block(lines, i + 1, pind)
        name = '?'; label = None; rhs_at = None
        for a, l in enumerate(blk):
            if ind(l) != pind + 2: continue
            s = l.lstrip()
            if s.startswith('|'): label = s.split(':', 1)[0]; continue
            if s.startswith('\\_') and label == '|vpiLhs':
                mm = re.search(r'\\_parameter: \(([^)]*)\)', s)
                if mm: name = mm.group(1)
            if s.startswith('\\_') and label == '|vpiRhs': rhs_at = a
        if rhs_at is None or not blk[rhs_at].lstrip().startswith('\\_operation:'):
            continue
        rind = ind(blk[rhs_at])
        rblk, _ = block(blk, rhs_at + 1, rind)
        label = None; a = 0
        while a < len(rblk):
            l = rblk[a]
            if ind(l) != rind + 2: a += 1; continue
            s = l.lstrip()
            if s.startswith('|'): label = s.split(':', 1)[0]; a += 1; continue
            if s.startswith('\\_'):
                sub, _ = block(rblk, a + 1, rind + 2)
                kind = re.match(r'\\_(\w+):', s).group(1)
                if label == '|vpiOperand':
                    mm = re.search(r'(line:[\d:]+, endln:[\d:]+)', s)
                    loc = mm.group(1) if mm else '?'
                    if kind == 'constant':
                        out[(sect, name, loc)][payload(sub, rind + 2)] += 1
                    else:
                        out[(sect, name, loc)][('<' + kind + '>',)] += 1
            a += 1
    return out

g, p, l, arm = sys.argv[1:5]
G, P, L = parse(g), parse(p), parse(l)
if not G:
    print('FATAL: golden has no op-Rhs param_assign'); sys.exit(4)
to = away = w2 = still = same = 0
for k in sorted(set(G) | set(P) | set(L)):
    gc, pc, lc = G.get(k, collections.Counter()), P.get(k, collections.Counter()), L.get(k, collections.Counter())
    if pc == lc:
        continue
    npg, nlg = sum((gc & pc).values()), sum((gc & lc).values())
    if nlg > npg:
        to += 1
    elif nlg < npg:
        away += 1
        print('  *** AWAY %-14s %-26s %-34s G=%s P=%s L=%s' %
              (k[0], k[1], k[2], sorted(gc.elements()), sorted(pc.elements()), sorted(lc.elements())))
    else:
        w2 += 1
        print('  W2   %-14s %-26s %-34s G=%s P=%s L=%s' %
              (k[0], k[1], k[2], sorted(gc.elements()), sorted(pc.elements()), sorted(lc.elements())))
print('ARM %-40s LOCKEY changed-slots TO=%d AWAY=%d W2=%d' % (arm, to, away, w2))
