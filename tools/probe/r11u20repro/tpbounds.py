#!/usr/bin/env python3
"""List every type_parameter's typespec RANGE BOUND shape from a uhdm-dump.

For each type_parameter object the dump prints in full, walk to its
ref_typespec -> vpiActual typespec and, when that typespec is printed in full
anywhere in the dump, report each vpiRange's vpiLeftRange / vpiRightRange as a
compact SHAPE string (constant encodings, operation op types, ref_obj names,
sys_func_call names).  An abbreviated repeat is resolved to the full print of
the object it names.

usage: tpbounds.py <dump>            -- one column
       tpbounds.py <gold> <ours>     -- side by side, marking != cells
"""
import re, sys, collections

HDR = re.compile(r'^(\s*)\\_(\w+): ?(\([^)]*\))?(.*)$')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')

class Node:
    __slots__ = ('kind','name','loc','fields','kids','parent')
    def __init__(self, kind, name, loc):
        self.kind = kind; self.name = name; self.loc = loc
        self.fields = []          # (fieldname, [Node...] or str)
        self.kids = []
        self.parent = None

def parse(path):
    """Build a forest from the indented dump."""
    lines = open(path, errors='replace').read().split('\n')
    roots = []
    stack = []                     # (indent, Node, pending-field-name)
    curfield = {}                  # id(node) -> field name awaiting a child
    for ln in lines:
        m = FLD.match(ln)
        if m:
            ind, fname, rest = len(m.group(1)), m.group(2), m.group(3)
            while stack and stack[-1][0] >= ind:
                stack.pop()
            if not stack:
                continue
            node = stack[-1][1]
            if rest.strip() == '':
                curfield[id(node)] = fname
            else:
                node.fields.append((fname, rest.strip()))
                curfield.pop(id(node), None)
            continue
        m = HDR.match(ln)
        if not m:
            continue
        ind = len(m.group(1))
        kind = m.group(2)
        name = (m.group(3) or '')[1:-1] if m.group(3) else ''
        loc  = m.group(4).strip().lstrip(',').strip()
        n = Node(kind, name, loc)
        while stack and stack[-1][0] >= ind:
            stack.pop()
        if stack:
            p = stack[-1][1]
            n.parent = p
            f = curfield.pop(id(p), None)
            p.fields.append((f or '?', n))
            p.kids.append((f or '?', n))
        else:
            roots.append(n)
        stack.append((ind, n, None))
    return roots

def index_full(roots):
    """kind+name+loc -> the node with the MOST children (the full print)."""
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
    k = (n.kind, n.name, n.loc)
    f = idx.get(k)
    return f if f is not None and len(f.kids) > len(n.kids) else n

def sval(n):
    for f, v in n.fields:
        if isinstance(v, str) and (':' in f or True):
            pass
    return None

def shape(n, idx, depth=0):
    if n is None:
        return 'NONE'
    if depth > 6:
        return '...'
    n = resolve(n, idx)
    if n.kind == 'constant':
        enc = 'ENC?'
        sz = ct = '?'
        for f, v in n.fields:
            if not isinstance(v, str):
                continue
            if f in ('UINT','INT','BIN','HEX','OCT','DEC','STRING','REAL','SCALAR'):
                enc = f + ':' + v
            elif f == 'vpiSize':
                sz = v
            elif f == 'vpiConstType':
                ct = v
        return 'const(%s,sz=%s,ct=%s)' % (enc, sz, ct)
    if n.kind == 'ref_obj':
        return 'ref(%s)' % (n.name.split('.')[-1] if n.name else '?')
    if n.kind == 'operation':
        op = '?'
        for f, v in n.fields:
            if isinstance(v, str) and f == 'vpiOpType':
                op = v
        ops = [shape(c, idx, depth+1) for f, c in n.kids if f == 'vpiOperand']
        return 'op%s[%s]' % (op, ','.join(ops))
    if n.kind == 'sys_func_call':
        args = [shape(c, idx, depth+1) for f, c in n.kids if f == 'vpiArgument']
        return 'sys(%s)[%s]' % (n.name or '?', ','.join(args))
    if n.kind == 'func_call':
        args = [shape(c, idx, depth+1) for f, c in n.kids if f == 'vpiArgument']
        return 'call(%s)[%s]' % (n.name or '?', ','.join(args))
    if n.kind == 'hier_path':
        return 'hier(%s)' % (n.name or '?')
    return '%s' % n.kind

def section_of(n):
    while n.parent is not None:
        n = n.parent
    return n

def cells(path):
    roots = parse(path)
    idx = index_full(roots)
    # section label per top-level: walk the raw file for |uhdmXXX: markers
    out = collections.OrderedDict()
    seen = set()
    def walk(n, sect):
        if n.kind == 'type_parameter':
            n2 = resolve(n, idx)
            ts = None
            for f, c in n2.kids:
                if f == 'vpiTypespec' and c.kind == 'ref_typespec':
                    c2 = resolve(c, idx)
                    for f2, a in c2.kids:
                        if f2 == 'vpiActual':
                            ts = resolve(a, idx)
            key = n2.name or n2.loc
            if ts is None:
                out.setdefault(key, []).append('TS=NONE')
            else:
                rs = [c for f, c in ts.kids if f == 'vpiRange']
                if not rs:
                    out.setdefault(key, []).append('%s dims=0' % ts.kind)
                for r in rs:
                    r = resolve(r, idx)
                    L = R = None
                    for f, c in r.kids:
                        if f == 'vpiLeftRange':  L = c
                        if f == 'vpiRightRange': R = c
                    out.setdefault(key, []).append(
                        '%s L=%s R=%s' % (ts.kind, shape(L, idx), shape(R, idx)))
        for _, c in n.kids:
            walk(c, sect)
    for r in roots:
        walk(r, '')
    # de-duplicate identical repeats per key
    for k in out:
        seen2 = []
        for v in out[k]:
            if v not in seen2:
                seen2.append(v)
        out[k] = seen2
    return out

def main():
    if len(sys.argv) == 2:
        for k, v in cells(sys.argv[1]).items():
            print('%-40s %s' % (k, ' | '.join(v)))
        return
    g = cells(sys.argv[1]); o = cells(sys.argv[2])
    keys = list(g.keys()) + [k for k in o if k not in g]
    bad = 0
    for k in keys:
        gv = ' | '.join(g.get(k, ['<absent>']))
        ov = ' | '.join(o.get(k, ['<absent>']))
        mark = '  ' if gv == ov else '!!'
        if gv != ov: bad += 1
        print('%s %-34s G: %-52s O: %s' % (mark, k, gv, ov))
    print('DIFFCELLS=%d TOTAL=%d' % (bad, len(keys)))

main()
