#!/usr/bin/env python3
"""r11u104 cell reader — every `cont_assign` at ANY depth (module body,
generate scope, def view, elaborated view), keyed on the LHS NAME plus the
occurrence index of that name (the multiset trap: two views of one net are two
cells, never one), with the RHS object kind and, for a constant, its four
compared fields.  A golden non-constant RHS is NOFOLD (GOLDEN WRITES NOTHING).
Also reads a variable's initializer (`|vpiExpr:` under a logic_var/
logic_net with an initializer) keyed `<name>@expr`."""
import re, sys

def _const(lines):
    c = '\n'.join(lines)
    d = re.search(r'\|vpiDecompile:([^\n]*)', c)
    s = re.search(r'\|vpiSize:(-?\d+)', c)
    v = re.search(r'\|((?:INT|UINT|HEX|BIN|DEC|OCT|REAL|STRING|SCAL):[^\n]*)', c)
    t = re.search(r'\|vpiConstType:(\d+)', c)
    return {'kind': 'constant', 'v': v.group(1) if v else '?',
            'ct': t.group(1) if t else '?', 'sz': s.group(1) if s else '?',
            'd': d.group(1) if d else '?'}

def _ind(l):
    return len(l) - len(l.lstrip(' '))

def _child(L, i, end, field):
    """the object under `|<field>:` at line index range [i, end)."""
    for j in range(i, end):
        if L[j].strip() == f'|{field}:':
            k = j + 1
            if k >= end: return None
            m = re.match(r'\s*\\_([a-z_]+):\s*(\(([^)]*)\))?', L[k])
            if not m: return None
            kind, nm = m.group(1), (m.group(3) or '')
            base = _ind(L[k])
            e = k + 1
            while e < end and _ind(L[e]) > base: e += 1
            if kind == 'constant':
                r = _const(L[k:e])
            else:
                r = {'kind': kind}
            r['name'] = nm
            return r
    return None

def read(p):
    L = open(p, errors='replace').read().split('\n')
    res = {}
    cnt = {}
    for i, l in enumerate(L):
        m = re.match(r'^(\s*)\\_cont_assign: ', l)
        if not m: continue
        base = _ind(l)
        e = i + 1
        while e < len(L) and _ind(L[e]) > base: e += 1
        blk = L[i + 1:e]
        # restrict to this assign's own fields (depth base+2)
        lhs = _child(L, i + 1, e, 'vpiLhs')
        rhs = _child(L, i + 1, e, 'vpiRhs')
        if lhs is None: continue
        n = lhs['name'].split('.')[-1] or '?'
        nda = any(x.strip() == '|vpiNetDeclAssign:1' and _ind(x) == base + 2
                  for x in blk)
        key = n + ('' if nda else '@asn')
        cnt[key] = cnt.get(key, 0) + 1
        if cnt[key] > 1: key += f'#{cnt[key]}'
        res[key] = rhs if rhs else {'kind': 'none'}
    return res

if __name__ == '__main__':
    for k, v in sorted(read(sys.argv[1]).items()):
        print(k, v)
