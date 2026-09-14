#!/usr/bin/env python3
"""r11u20 KEYED directional census — golden vs pristine vs patched.

Two cell families, because a per-LINE multiset census is MISLEADING for both
laws (see the README): a symbolic bound is several objects where a folded one
is a single constant, so generic lines like `|vpiParent:` and `|vpiConstType:9`
inflate on every object we carry that golden does not, and the folded constants
the law removes are counted against unrelated `UINT:<n>` lines elsewhere.

  TP  every `type_parameter`'s typespec RANGE BOUND, keyed by
      (type-parameter full name, dim index, left|right) -> shape string.
  TF  every module_inst / interface_inst / program `vpiTaskFunc` listing,
      keyed by (section, instance full name) -> the sorted NAME list.

usage: cen20.py <gold.dump> <pris.dump> <pat.dump>
"""
import re, sys, collections

HDR = re.compile(r'^(\s*)\\_(\w+): ?(\([^)]*\))?(.*)$')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')


class Node:
    __slots__ = ('kind', 'name', 'loc', 'fields', 'kids', 'sect')

    def __init__(self, kind, name, loc, sect):
        self.kind, self.name, self.loc, self.sect = kind, name, loc, sect
        self.fields, self.kids = [], []


def parse(path):
    roots, stack, pend, sect = [], [], {}, ''
    for ln in open(path, errors='replace').read().split('\n'):
        m = re.match(r'^\|(uhdm\w+):', ln)
        if m:
            sect = m.group(1)
            continue
        m = FLD.match(ln)
        if m:
            ind, f, rest = len(m.group(1)), m.group(2), m.group(3)
            while stack and stack[-1][0] >= ind:
                stack.pop()
            if not stack:
                continue
            n = stack[-1][1]
            if rest.strip() == '':
                pend[id(n)] = f
            else:
                n.fields.append((f, rest.strip()))
                pend.pop(id(n), None)
            continue
        m = HDR.match(ln)
        if not m:
            continue
        ind = len(m.group(1))
        n = Node(m.group(2), (m.group(3) or '')[1:-1] if m.group(3) else '',
                 m.group(4).strip().lstrip(',').strip(), sect)
        while stack and stack[-1][0] >= ind:
            stack.pop()
        if stack:
            p = stack[-1][1]
            f = pend.pop(id(p), None) or '?'
            p.fields.append((f, n))
            p.kids.append((f, n))
        else:
            roots.append(n)
        stack.append((ind, n))
    return roots


def index_full(roots):
    best = {}

    def walk(n):
        k = (n.kind, n.name, n.loc)
        if k not in best or len(n.kids) > len(best[k].kids):
            best[k] = n
        for _, c in n.kids:
            walk(c)
    for r in roots:
        walk(r)
    return best


def resolve(n, idx):
    f = idx.get((n.kind, n.name, n.loc))
    return f if f is not None and len(f.kids) > len(n.kids) else n


def shape(n, idx, d=0):
    if n is None:
        return 'NONE'
    if d > 6:
        return '...'
    n = resolve(n, idx)
    if n.kind == 'constant':
        enc, sz, ct = 'ENC?', '?', '?'
        for f, v in n.fields:
            if not isinstance(v, str):
                continue
            if f in ('UINT', 'INT', 'BIN', 'HEX', 'OCT', 'DEC', 'STRING',
                     'REAL', 'SCALAR'):
                enc = f + ':' + v
            elif f == 'vpiSize':
                sz = v
            elif f == 'vpiConstType':
                ct = v
        return 'const(%s,sz=%s,ct=%s)' % (enc, sz, ct)
    if n.kind == 'ref_obj':
        # VpiName is the compared field; VpiFullName is NOT (ref_obj::Compare).
        nm = ''
        for f, v in n.fields:
            if isinstance(v, str) and f == 'vpiName':
                nm = v
        act = [c for f, c in n.kids if f == 'vpiActual']
        return 'ref(%s%s)' % (nm, '|bound' if act else '')
    if n.kind == 'operation':
        op = '?'
        for f, v in n.fields:
            if isinstance(v, str) and f == 'vpiOpType':
                op = v
        return 'op%s[%s]' % (op, ','.join(
            shape(c, idx, d + 1) for f, c in n.kids if f == 'vpiOperand'))
    if n.kind in ('sys_func_call', 'func_call'):
        return '%s(%s)[%s]' % (n.kind, n.name or '?', ','.join(
            shape(c, idx, d + 1) for f, c in n.kids if f == 'vpiArgument'))
    return n.kind


def cells(path):
    roots = parse(path)
    idx = index_full(roots)
    out = {}

    def walk(n, inst):
        here = inst
        if n.kind in ('module_inst', 'interface_inst', 'program'):
            here = (n.sect, n.name)
            out.setdefault(('TF',) + here, [])
        if n.kind == 'type_parameter':
            n2 = resolve(n, idx)
            ts = None
            for f, c in n2.kids:
                if f == 'vpiTypespec' and c.kind == 'ref_typespec':
                    for f2, a in resolve(c, idx).kids:
                        if f2 == 'vpiActual':
                            ts = resolve(a, idx)
            key0 = ('TP', n2.name or n2.loc)
            if ts is None:
                out[key0 + ('ts',)] = 'NONE'
            else:
                rs = [resolve(c, idx) for f, c in ts.kids if f == 'vpiRange']
                out[key0 + ('cls',)] = ts.kind
                out[key0 + ('dims',)] = str(len(rs))
                for i, r in enumerate(rs):
                    L = R = None
                    for f, c in r.kids:
                        if f == 'vpiLeftRange':
                            L = c
                        if f == 'vpiRightRange':
                            R = c
                    out[key0 + ('d%d.L' % i,)] = shape(L, idx)
                    out[key0 + ('d%d.R' % i,)] = shape(R, idx)
        for f, c in n.kids:
            if f == 'vpiTaskFunc' and here:
                out.setdefault(('TF',) + here, []).append(c.name or '?')
            walk(c, here)
    for r in roots:
        walk(r, None)
    for k, v in list(out.items()):
        if k[0] == 'TF':
            out[k] = '[' + ','.join(sorted(v)) + ']'
    return out


def main():
    g, p, q = (cells(a) for a in sys.argv[1:4])
    keys = sorted(set(g) | set(p) | set(q))
    to = away = still = 0
    for k in keys:
        gv, pv, qv = g.get(k, '<absent>'), p.get(k, '<absent>'), q.get(k, '<absent>')
        if pv == qv:
            if gv != qv:
                still += 1
            continue
        if qv == gv:
            to += 1
            print('  TO   %-46s %s -> %s' % ('/'.join(k), pv[:48], qv[:48]))
        elif pv == gv:
            away += 1
            print('  AWAY %-46s g=%s pris=%s pat=%s' % ('/'.join(k), gv[:36],
                                                        pv[:36], qv[:36]))
        else:
            print('  MOVED-STILL-WRONG %-32s g=%s pris=%s pat=%s' %
                  ('/'.join(k), gv[:32], pv[:32], qv[:32]))
    print('TO-GOLDEN=%d AWAY-GOLDEN=%d STILL-WRONG-UNMOVED=%d CELLS=%d' %
          (to, away, still, len(keys)))


main()
