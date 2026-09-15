#!/usr/bin/env python3
"""r11u41 — read the golden grid: per arm signal, the DEF-view and ELAB-view
SHAPE of the declaration object, deep enough to see the net/var kind, the
vpiNetType stamp, the object's OWN vpiTypespec, and (for a packed-array
container) the element's kind / name / typespec.

Dump shape (measured): an object header sits at indent I, its OWN fields at
I+2, and a child object that is the value of one of those fields also sits at
I+2 with its own fields at I+4 (the same reading r11u32's gridread.py makes).

Sections exactly as r11u32's readers cut them:
   DEF  = |uhdmallModules: .. |uhdmtopModules:
   ELAB = |uhdmtopModules: .. \\_weaklyReferenced:      (TAIL never read)
"""
import re, sys

OBJ = re.compile(r'^(\s*)\\?_?([a-z_0-9]+): \(([^)]*)\)')
OBJ2 = re.compile(r'^(\s*)\\?_?([a-z_0-9]+): *(,|$)')
FLD = re.compile(r'^(\s*)\|([A-Za-z]+):(.*)$')


class Node:
    __slots__ = ('kind', 'fn', 'ind', 'fields', 'kids')

    def __init__(self, kind, fn, ind):
        self.kind, self.fn, self.ind = kind, fn, ind
        self.fields = {}      # field name -> scalar text (first sighting)
        self.kids = []        # (field name, Node)


def parse(lines):
    root = Node('ROOT', '', -2)
    stack = [root]
    pending = None            # the field name a following child object belongs to
    for l in lines:
        m = OBJ.match(l) or OBJ2.match(l)
        if m:
            ind = len(m.group(1))
            kind = m.group(2)
            fn = m.group(3) if m.re is OBJ else ''
            while stack and stack[-1].ind >= ind:
                stack.pop()
            n = Node(kind, fn, ind)
            stack[-1].kids.append((pending or '', n))
            pending = None
            stack.append(n)
            continue
        m2 = FLD.match(l)
        if not m2:
            continue
        ind, field, val = len(m2.group(1)), m2.group(2), m2.group(3)
        while stack and stack[-1].ind >= ind:
            stack.pop()
        owner = stack[-1]
        if val.strip() == '':
            pending = field
        else:
            owner.fields.setdefault(field, val.strip())
            pending = None
    return root


def find(root, want, kinds=None):
    """outermost object whose fullname LEAF matches `want`."""
    out = {}

    def walk(n):
        leaf = n.fn.split('.')[-1] if n.fn else ''
        if leaf and want(leaf) and (kinds is None or n.kind in kinds) \
                and leaf not in out:
            out[leaf] = n
            return                      # outermost sighting only
        for _, k in n.kids:
            walk(k)
    walk(root)
    return out


def kid(n, field):
    for f, k in n.kids:
        if f == field:
            return k
    return None


def tsig(n, field='vpiTypespec'):
    """'<actual kind>' for an object's own typespec ref, or '-'"""
    rt = kid(n, field)
    if rt is None:
        return '-'
    act = kid(rt, 'vpiActual')
    return act.kind if act else '?'


def psig(n):
    """the PORT object's vpiTypedef target (the port's written data type)."""
    return 'ABSENT' if n is None else tsig(n, 'vpiTypedef')


def sig(n):
    if n is None:
        return 'ABSENT'
    s = n.kind
    nt = n.fields.get('vpiNetType')
    s += f' nt={nt}' if nt else ' nt=-'
    s += f' ts={tsig(n)}'
    el = kid(n, 'vpiElement')
    if el is not None:
        s += f' | el={el.kind}'
        s += ' nm=' + ('y' if 'vpiName' in el.fields else 'n')
        s += f' ts={tsig(el)}'
    return s


def sections(path):
    lines = open(path, errors='replace').read().split('\n')
    d = e = t = None
    for i, l in enumerate(lines):
        s = l.strip()
        if s == '|uhdmallModules:' and d is None:
            d = i
        elif s == '|uhdmtopModules:' and e is None:
            e = i
        elif s.startswith('\\_weaklyReferenced:') and t is None:
            t = i
    n = len(lines)
    return lines[(d or 0):(e or n)], lines[(e or n):(t or n)]


def main():
    g, o = sys.argv[1], sys.argv[2]
    want = lambda leaf: leaf.startswith('x_')
    gd, ge = sections(g)
    od, oe = sections(o)
    tgd, tge, tod, toe = parse(gd), parse(ge), parse(od), parse(oe)
    GD, GE = find(tgd, want), find(tge, want)
    OD, OE = find(tod, want), find(toe, want)
    GP, OP = find(tgd, want, {'port'}), find(tod, want, {'port'})
    GQ, OQ = find(tge, want, {'port'}), find(toe, want, {'port'})
    names = sorted(set(GD) | set(OD) | set(GE) | set(OE))
    nd = ne = npt = 0
    print(f'{"ARM":20s} | {"DEF golden":26s} | {"DEF ours":26s} | '
          f'{"ELAB golden":52s} | {"ELAB ours":52s} | '
          f'{"PORTts g/o (def|elab)":56s} | VERDICT')
    for n in names:
        a, b = sig(GD.get(n)), sig(OD.get(n))
        c, d = sig(GE.get(n)), sig(OE.get(n))
        pg = f'{psig(GP.get(n))}|{psig(GQ.get(n))}'
        po = f'{psig(OP.get(n))}|{psig(OQ.get(n))}'
        pp = f'{pg} vs {po}'
        vd = '' if a == b else 'DEF-DIFF'
        ve = '' if c == d else 'ELAB-DIFF'
        vp = '' if pg == po else 'PORT-DIFF'
        nd += bool(vd)
        ne += bool(ve)
        npt += bool(vp)
        print(f'{n:20s} | {a:26s} | {b:26s} | {c:52s} | {d:52s} | '
              f'{pp:56s} | {vd} {ve} {vp}')
    print('-- PORT typespec (port vpiTypedef actual), def|elab:')
    for n in names:
        pg = f'{psig(GP.get(n))}|{psig(GQ.get(n))}'
        po = f'{psig(OP.get(n))}|{psig(OQ.get(n))}'
        if pg == 'ABSENT|ABSENT' and po == 'ABSENT|ABSENT':
            continue
        print(f'   {n:20s} golden {pg:38s} ours {po:38s} '
              f'{"PORT-DIFF" if pg != po else ""}')
    print(f'-- arms: {len(names)}   DEF-DIFF: {nd}   ELAB-DIFF: {ne}   '
          f'PORT-DIFF: {npt}')


main()
