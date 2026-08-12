#!/usr/bin/env python3
"""r10uvm57repro/cells.py -- THE ARM CELL TABLE.

One cell per REFERENCE (ref_obj / ref_var) in a uhdm-dump: its name, span, the
FIELD it hangs off (vpiArgument / vpiLhs / vpiOperand / ...), the KIND of the
node it hangs off (func_call / sys_func_call / assignment / ...), and whether it
carries a vpiActual -- read at the reference's OWN CHILD DEPTH (header indent +
2), never anywhere in its subtree.  Nested references are separate cells.

  usage: cells.py <g.dump> <o.dump> [name-substring-filter]

Golden is ALWAYS the first argument.  A differing count is printed last; that
number, not the table, is the arm's verdict.

WHY OWN CHILD DEPTH: `|vpiActual:` appears under a ref's own ref_typespec child
too, and a subtree grep counts those.  Only depth == indent+2 is the ref's own.
"""
import re
import sys

HDR = re.compile(r'^(\s*)\\_(\w+): (\([^)]*\))?,? ?(line:\d+:\d+, endln:\d+:\d+)?')
FIELD = re.compile(r'^(\s*)\|(\w+):\s*$')
ANYFIELD = re.compile(r'^(\s*)\|(\w+):')


def parse(path):
    """-> list of cells (name, span, field, parentkind, bound)."""
    lines = open(path).read().split('\n')
    # stack of (indent, kind, name) for header lines
    stack = []
    # last field label seen at each indent
    fieldat = {}
    cells = []
    for i, ln in enumerate(lines):
        mf = FIELD.match(ln)
        if mf:
            fieldat[len(mf.group(1))] = mf.group(2)
            continue
        m = HDR.match(ln)
        if not m:
            continue
        ind = len(m.group(1))
        kind = m.group(2)
        name = (m.group(3) or '()')[1:-1]
        span = m.group(4) or ''
        while stack and stack[-1][0] >= ind:
            stack.pop()
        parentkind = stack[-1][1] if stack else '<root>'
        field = fieldat.get(ind, '?')
        stack.append((ind, kind, name))
        if kind not in ('ref_obj', 'ref_var'):
            continue
        # own child depth == ind + 2; scan forward until a line at depth <= ind
        bound = False
        j = i + 1
        while j < len(lines):
            l2 = lines[j]
            if not l2.strip():
                j += 1
                continue
            ind2 = len(l2) - len(l2.lstrip())
            if ind2 <= ind:
                break
            if ind2 == ind + 2:
                a = ANYFIELD.match(l2)
                if a and a.group(2) == 'vpiActual':
                    bound = True
                    break
            j += 1
        cells.append((name, span, field, parentkind, bound))
    return cells


def key(c):
    return (c[0], c[1], c[2], c[3])


def main():
    g, o = sys.argv[1], sys.argv[2]
    filt = sys.argv[3] if len(sys.argv) > 3 else ''
    gc = [c for c in parse(g) if filt in c[0]]
    oc = [c for c in parse(o) if filt in c[0]]
    gm, om = {}, {}
    for c in gc:
        gm.setdefault(key(c), []).append(c[4])
    for c in oc:
        om.setdefault(key(c), []).append(c[4])
    allk = sorted(set(gm) | set(om))
    print('golden refs=%d  ours refs=%d  distinct cells=%d' % (len(gc), len(oc), len(allk)))
    print('%-46s %-30s %-14s %-16s %-9s %-9s %s' %
          ('NAME', 'SPAN', 'FIELD', 'PARENT-KIND', 'GOLD', 'OURS', ''))
    diff = 0
    for k in allk:
        gv, ov = gm.get(k), om.get(k)
        gs = 'ABSENT' if gv is None else '/'.join('B' if x else 'b' for x in gv)
        os_ = 'ABSENT' if ov is None else '/'.join('B' if x else 'b' for x in ov)
        tag = ''
        if gs != os_:
            diff += 1
            if gv and ov:
                tag = 'UNDERBIND' if gv.count(True) > ov.count(True) else 'OVERBIND'
            else:
                tag = 'MISSING' if gv else 'EXTRA'
        print('%-46s %-30s %-14s %-16s %-9s %-9s %s' %
              (k[0][:46], k[1].replace('line:', '').replace(' endln:', '-'),
               k[2], k[3], gs, os_, tag))
    print('B = carries vpiActual at own child depth, b = does not')
    print('DIFFERING CELLS: %d / %d' % (diff, len(allk)))


main()
