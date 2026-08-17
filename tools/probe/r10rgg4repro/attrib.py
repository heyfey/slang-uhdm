#!/usr/bin/env python3
"""r10rgg4/attrib.py — pull every RANGE-BOUND constant out of a uhdm-dump.

One line per measured constant:

  <scope>|<site-kind>(<site-name>)@<site-loc> <slot> sz=<N> <VALUE> ct=<N> ts=<Y/N:kind> @<loc>

where <slot> is LEFT, ROP0 (the first operand of the right-bound operation),
ROP1, or RIGHT (a non-operation right bound).  Emitting a line for EVERY bound
of EVERY range is deliberate: a cell whose interesting range vanished must read
as a MISSING LINE, never as agreement.

GUARD: a dump that yields zero lines exits 3 (so `NO-GOLDEN` is impossible to
mistake for a match).
"""
import re, sys

OBJ = re.compile(r'^(\s*)\\_(\w+):\s*(?:\(([^)]*)\))?(.*)$')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')
BACKREF = {'vpiParent', 'vpiTypedef', 'vpiActual_group'}


class Node:
    __slots__ = ('kind', 'name', 'tail', 'fields', 'kids', 'indent')

    def __init__(self, kind, name, tail, indent):
        self.kind, self.name, self.tail, self.indent = kind, name or '', tail, indent
        self.fields = {}
        self.kids = []      # list of (fieldname, Node)


def parse(path):
    roots = []
    stack = []          # (indent, Node)
    pending = None      # (indent, fieldname) awaiting an object
    with open(path, errors='replace') as f:
        for ln in f:
            ln = ln.rstrip('\n')
            m = FLD.match(ln)
            if m:
                ind, nm, val = len(m.group(1)), m.group(2), m.group(3)
                while stack and stack[-1][0] >= ind:
                    stack.pop()
                if val.strip():
                    if stack:
                        stack[-1][1].fields[nm] = val.strip()
                    pending = None
                else:
                    pending = (ind, nm)
                continue
            m = OBJ.match(ln)
            if not m:
                pending = None
                continue
            ind = len(m.group(1))
            node = Node(m.group(2), m.group(3), m.group(4).strip(), ind)
            while stack and stack[-1][0] >= ind:
                stack.pop()
            fname = pending[1] if (pending and pending[0] == ind) else ''
            pending = None
            if stack:
                stack[-1][1].kids.append((fname, node))
            else:
                roots.append(node)
            if fname in BACKREF:
                # a back-reference stub: never descend into it
                node.kind = '#backref#' + node.kind
            stack.append((ind, node))
    return roots


def loc(n):
    m = re.search(r'line:(\d+):(\d+)(?:, endln:(\d+):(\d+))?', n.tail)
    if not m:
        return '-'
    if m.group(3):
        return f'{m.group(1)}:{m.group(2)}-{m.group(3)}:{m.group(4)}'
    return f'{m.group(1)}:{m.group(2)}'


def valof(n):
    for k in ('UINT', 'INT', 'BIN', 'HEX', 'OCT', 'DEC', 'STRING', 'REAL',
              'SCAL', 'UINT64'):
        if k in n.fields:
            return f'{k}:{n.fields[k]}'
    return 'novalue'


def tsof(n):
    for fn, kid in n.kids:
        if fn == 'vpiTypespec':
            real = kid
            k = real.kind.replace('#backref#', '')
            if k == 'ref_typespec':
                inner = [c for f, c in real.kids if f == 'vpiActual']
                ik = inner[0].kind if inner else '?'
                return f'Y:{ik}'
            return f'Y:{k}'
    return 'N'


def desc(n):
    if n.kind != 'constant':
        return f'{n.kind}[{loc(n)}]'
    return (f'sz={n.fields.get("vpiSize","-")} {valof(n)} '
            f'ct={n.fields.get("vpiConstType","-")} ts={tsof(n)} '
            f'dec={n.fields.get("vpiDecompile","-")} @{loc(n)}')


def emit(out, scope, site, r):
    slots = []
    for fn, kid in r.kids:
        if fn == 'vpiLeftRange':
            slots.append(('LEFT', kid))
        elif fn == 'vpiRightRange':
            if kid.kind == 'operation':
                ops = [c for f, c in kid.kids if f == 'vpiOperand']
                slots.append((f'ROP(op{kid.fields.get("vpiOpType","?")})',
                              None))
                for i, o in enumerate(ops):
                    slots.append((f'ROP{i}', o))
            else:
                slots.append(('RIGHT', kid))
    for slot, k in slots:
        if k is None:
            out.append(f'{scope}|{site} {slot}')
        else:
            out.append(f'{scope}|{site} {slot} {desc(k)}')


def walk(n, scope, out, path=()):
    kind = n.kind
    if kind.startswith('#backref#'):
        return
    nm = n.fields.get('vpiFullName') or n.name
    if kind in ('module_inst', 'interface_inst', 'package', 'program',
                'gen_scope', 'gen_scope_array', 'design'):
        scope = nm or scope
    if kind == 'range':
        site = f'{path[-1] if path else "?"}'
        emit(out, scope, site, n)
        return
    site = f'{kind}({nm})@{loc(n)}'
    for fn, kid in n.kids:
        walk(kid, scope, out, path + (site,))


def main():
    out = []
    for r in parse(sys.argv[1]):
        walk(r, '<root>', out)
    seen = set()
    for l in out:
        if l in seen:
            continue
        seen.add(l)
        print(l)
    if not out:
        sys.exit(3)


if __name__ == '__main__':
    main()
