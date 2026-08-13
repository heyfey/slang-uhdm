#!/usr/bin/env python3
"""r10earl42 GRID — one row per (listing scope, parameter cell), reporting the
operand ORDER and the vpiReordered flag on BOTH sides.

    usage: grid42.py <g.dump> <o.dump>

LHS is ALWAYS golden (Surelog).  RHS is ALWAYS ours.

The cell is identified by the PARAM_ASSIGN's Lhs parameter NAME, which the arm
source encodes (B1_.., C3_.., D1_..), so a row survives span drift.  Rows the
two sides do not both have are printed as GOLDEN_ONLY / OURS_ONLY — never
silently dropped.
"""
import re
import sys
from collections import OrderedDict

OBJ = re.compile(r'^( *)(?:\\_)?([a-z_0-9]+): (.*)$')
FLD = re.compile(r'^( *)\|([A-Za-z_0-9]+):(.*)$')
SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')


def parse(path):
    section = None
    stack = []          # [indent, kind, span, name, pending_field, rec]
    rows = OrderedDict()
    scopestack = []

    def close_to(ind):
        while stack and stack[-1][0] >= ind:
            fin = stack.pop()
            if fin[5] is not None and fin[5].get('emit'):
                r = fin[5]
                key = (r['section'], r['scope'], r['pname'])
                rows.setdefault(key, r)
        while scopestack and scopestack[-1][0] >= ind:
            scopestack.pop()

    with open(path, errors='replace') as fh:
        for raw in fh:
            line = raw.rstrip('\n')
            if not line:
                continue
            if line.startswith('|uhdm') and line.endswith(':'):
                section = line[5:-1]
                close_to(0)
                continue
            m = FLD.match(line)
            if m:
                ind, name, val = len(m.group(1)), m.group(2), m.group(3)
                close_to(ind)
                if not stack:
                    continue
                owner = stack[-1]
                owner[4] = name
                r = owner[5]
                if r is not None and owner[1] == 'param_assign':
                    pass
                if owner[1] == 'operation' and r is not None:
                    if name == 'vpiOpType':
                        r['optype'] = val.strip()
                    elif name == 'vpiReordered':
                        r['reordered'] = True
                continue
            m = OBJ.match(line)
            if m:
                ind, kind, rest = len(m.group(1)), m.group(2), m.group(3)
                close_to(ind)
                parent = stack[-1] if stack else None
                pfield = parent[4] if parent else None
                if pfield == 'vpiParent':
                    continue
                sm = SPAN.search(rest)
                span = ('%s:%s-%s:%s' % sm.groups()) if sm else '?'
                nm = rest.split(',')[0].strip()
                rec = None
                if kind == 'param_assign':
                    rec = {'section': section,
                           'scope': scopestack[-1][1] if scopestack else '?',
                           'pname': None, 'optype': None, 'reordered': False,
                           'operands': [], 'emit': False, 'span': span}
                if parent is not None and parent[1] == 'param_assign' \
                        and parent[5] is not None:
                    pr = parent[5]
                    if pfield == 'vpiLhs' and kind == 'parameter':
                        pr['pname'] = nm
                    elif pfield == 'vpiRhs' and kind == 'operation':
                        pr['emit'] = True
                        rec = pr          # the operation writes into the row
                if parent is not None and parent[1] == 'operation' \
                        and parent[5] is not None and pfield == 'vpiOperand':
                    parent[5]['operands'].append(span)
                    rec = None
                stack.append([ind, kind, span, nm, None, rec])
                if kind in ('module_inst', 'package', 'interface_inst'):
                    scopestack.append((ind, nm))
    close_to(-1)
    return rows


def classify(ops):
    if len(ops) <= 1:
        return 'SINGLE'
    keys = []
    for sp in ops:
        try:
            a, b = sp.split('-')[0].split(':')
            keys.append((int(a), int(b)))
        except Exception:
            return 'NOSPAN'
    if all(keys[i] < keys[i + 1] for i in range(len(keys) - 1)):
        return 'ASC'
    if all(keys[i] > keys[i + 1] for i in range(len(keys) - 1)):
        return 'DESC'
    return 'MIXED'


def main():
    g = parse(sys.argv[1])
    o = parse(sys.argv[2])
    keys = list(g.keys()) + [k for k in o if k not in g]
    print('%-14s %-34s %-16s | %-6s %-5s %-4s | %-6s %-5s %-4s | %s'
          % ('section', 'scope', 'param', 'g.ord', 'g.rd', 'g.op',
             'o.ord', 'o.rd', 'o.op', 'VERDICT'))
    for k in keys:
        gr, orr = g.get(k), o.get(k)
        if gr is None:
            print('%-14s %-34s %-16s | %-6s %-5s %-4s | %-6s %-5s %-4s | OURS_ONLY'
                  % (k[0], k[1], k[2], '-', '-', '-',
                     classify(orr['operands']), orr['reordered'], orr['optype']))
            continue
        if orr is None:
            print('%-14s %-34s %-16s | %-6s %-5s %-4s | %-6s %-5s %-4s | GOLDEN_ONLY'
                  % (k[0], k[1], k[2], classify(gr['operands']),
                     gr['reordered'], gr['optype'], '-', '-', '-'))
            continue
        gc, oc = classify(gr['operands']), classify(orr['operands'])
        v = 'MATCH' if (gc == oc and gr['reordered'] == orr['reordered']
                        and gr['optype'] == orr['optype']) else 'DIFFER'
        print('%-14s %-34s %-16s | %-6s %-5s %-4s | %-6s %-5s %-4s | %s'
              % (k[0], k[1], k[2], gc, gr['reordered'], gr['optype'],
                 oc, orr['reordered'], orr['optype'], v))


main()
