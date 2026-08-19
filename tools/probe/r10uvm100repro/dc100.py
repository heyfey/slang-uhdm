#!/usr/bin/env python3
"""r10uvm100 -- MEASUREMENT ONLY.  One row per `delay_control` in a uhdm-dump
tree (the dump tree is exactly the REACHABLE set, so no row can name an object
the judge cannot see).

KEY   = (SITE, nearest named ancestor, ANCHOR) where ANCHOR is the span of the
        delay_control's DELAYED STATEMENT (statement position) or of its OWNER
        (intra-assignment / net / gate position).  The anchor is deliberately
        NOT the delay_control's own span -- that span is one of the values
        under measurement.
VALUE = the delay_control's own span, its vpiDelay STRING, and its Delay()
        object's kind / vpiName / span.
Never the file, never the source text.
Usage: dc100.py <dump> [SITE]
"""
import re, sys

OBJ = re.compile(r'^(\s*)\\_([A-Za-z_0-9]+): (?:\(([^)]*)\))?,?\s*(?:id:\d+, )?'
                 r'(?:line:(\d+):(\d+), endln:(\d+):(\d+))?')
FLD = re.compile(r'^(\s*)\|(.*)$')


class Node:
    __slots__ = ('kind', 'name', 'span', 'label', 'fields', 'kids', 'indent')

    def __init__(self, kind, name, span, label, indent):
        self.kind, self.name, self.span = kind, name, span
        self.label, self.indent = label, indent
        self.fields, self.kids = [], []


def parse(path):
    roots, stack, pending = [], [], None
    for line in open(path, errors='replace'):
        line = line.rstrip('\n')
        if not line.strip():
            continue
        m = OBJ.match(line)
        if m:
            ind = len(m.group(1))
            span = ('%s:%s-%s:%s' % (m.group(4), m.group(5), m.group(6), m.group(7))
                    if m.group(4) else '')
            n = Node(m.group(2), m.group(3) or '', span, pending, ind)
            while stack and stack[-1].indent >= ind:
                stack.pop()
            (stack[-1].kids if stack else roots).append(n)
            stack.append(n)
            pending = None
            continue
        m = FLD.match(line)
        if m:
            ind, body = len(m.group(1)), m.group(2)
            while stack and stack[-1].indent + 2 > ind:
                stack.pop()
            if stack:
                stack[-1].fields.append(body)
            pending = body[:-1] if body.endswith(':') else None
    return roots


def refname(d):
    """The object's OWN vpiName -- never the dump's `(...)` header, which is a
    SYNTHESIZED vpiFullName built from the parent chain (a nameless ref there
    prints its enclosing scope)."""
    for f in d.fields:
        if f.startswith('vpiName:'):
            return f[len('vpiName:'):]
    return '<nameless>'


def walk(n, scope, out, site):
    # nearest NAMED ancestor, back-references excluded
    myscope = scope
    if n.name:
        myscope = n.name
    if n.kind == 'delay_control' and n.label != 'vpiParent':
        stmt = [k for k in n.kids if k.label == 'vpiStmt']
        delay = [k for k in n.kids if k.label == 'vpiDelay']
        par = [k for k in n.kids if k.label == 'vpiParent']
        if stmt:
            anchor = 'STMT ' + stmt[0].kind + '@' + stmt[0].span
            pos = 'statement'
        else:
            anchor = 'OWNER ' + (par[0].kind + '@' + par[0].span if par else '?')
            pos = 'nonstatement'
        # the vpiDelay STRING is a bare field line with no `vpiXxx:` label
        strs = [f for f in n.fields
                if not re.match(r'^vpi[A-Za-z_0-9]*:?$', f) and ':' not in f]
        d = delay[0] if delay else None
        val = 'dcspan=%s str=%s ref=%s' % (
            n.span, ('|'.join(strs) if strs else '-'),
            ('%s/%s/%s/actual=%s' % (d.kind, refname(d), d.span,
                                     'y' if any(f.startswith('vpiActual')
                                                for f in d.fields) else 'n'))
            if d else '-')
        out.append(('%s\t%s\t%s\t%s' % (site, scope, pos + ' ' + anchor, val)))
    for k in n.kids:
        if k.label == 'vpiParent':
            continue
        walk(k, myscope, out, site)


def main():
    site = sys.argv[2] if len(sys.argv) > 2 else 'X'
    out = []
    for r in parse(sys.argv[1]):
        walk(r, '', out, site)
    for l in sorted(out):
        print(l)


main()
