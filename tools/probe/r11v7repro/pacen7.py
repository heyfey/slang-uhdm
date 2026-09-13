#!/usr/bin/env python3
"""r11u7 CENSUS — the COMPARE-VISIBLE param_assign grid of one database,
keyed by (view fullname, parameter name).  Used to score agreement against
GOLDEN, never against the other binary alone.

  pacen7.py <dump>                 -> `view|param|ovr|shape` rows
  pacen7.py <golden> <a> [<b>]     -> agreement of a (and b) against golden,
                                      naming every row that a AGREES on and b
                                      does not (LOST) and vice versa (GAIN).

The shape keeps only fields a generated `Compare` reads (kind, vpiOpType,
vpiSize, the value line, the typespec's NAME) -- no span, id, fullname or
parent.  A row missing from a side is `<absent>`, never silently skipped.
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pashape

def rows(path):
    root = pashape.build(pashape.parse(path))
    out = {}
    seen = set()
    def visit(n):
        import re
        if n.kind != 'interface_inst':
            return
        m = re.match(r'interface_inst:\s*(\S+)\s*\((.*?)\)', n.head)
        if not m:
            return
        view = m.group(2)
        pas = [k for lab, k in n.kids if lab == 'vpiParamAssign']
        if not pas or view in seen:
            return
        seen.add(view)
        for pa in pas:
            lhs = [k for lab, k in pa.kids if lab == 'vpiLhs']
            rhs = [k for lab, k in pa.kids if lab == 'vpiRhs']
            pname = ''
            if lhs:
                pname = lhs[0].fields.get('vpiName', '')
                if not pname:
                    mm = re.search(r'\((.*?)\)', lhs[0].head)
                    pname = (mm.group(1).rsplit('.', 1)[-1] if mm else '?')
            out[(view, pname)] = 'ovr=%s %s' % (
                pa.fields.get('vpiOverriden', '0'),
                pashape.shape(rhs[0]) if rhs else '<null>')
    pashape.walk(root, visit)
    return out

def score(g, x):
    return sum(1 for k, v in g.items() if x.get(k) == v)

def main(argv):
    if len(argv) == 1:
        for k, v in sorted(rows(argv[0]).items()):
            print('%-30s %-10s %s' % (k[0], k[1], v))
        return 0
    g = rows(argv[0])
    sides = [(p, rows(p)) for p in argv[1:]]
    print('golden rows %d' % len(g))
    for p, r in sides:
        print('  %-40s agree %d' % (os.path.basename(os.path.dirname(p)) + '/' +
                                    os.path.basename(p), score(g, r)))
    if len(sides) == 2:
        a, b = sides[0][1], sides[1][1]
        lost = [k for k, v in g.items() if a.get(k) == v and b.get(k) != v]
        gain = [k for k, v in g.items() if a.get(k) != v and b.get(k) == v]
        for k in sorted(lost):
            print('  LOST %-26s %-8s golden=%s  b=%s' %
                  (k[0], k[1], g[k], b.get(k, '<absent>')))
        for k in sorted(gain):
            print('  GAIN %-26s %-8s golden=%s' % (k[0], k[1], g[k]))
        print('  LOST %d  GAIN %d' % (len(lost), len(gain)))
    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
