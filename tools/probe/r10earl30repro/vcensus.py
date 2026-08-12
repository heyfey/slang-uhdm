#!/usr/bin/env python3
"""r10earl30 VERIFIER's INDEPENDENT census — deliberately a DIFFERENT
implementation from the implementer's dumpread.py/ctcensus.py, so that agreement
between the two is evidence and not a shared bug.

Their reader walks forward from an object header and skips introduced subtrees by
indent comparison.  This one instead maintains an EXPLICIT STACK of open objects
and attributes each `|field:` line to whatever object is on top of the stack at
that field's parent depth.  Same answer by a different route, or one of us is
wrong.

  usage: vcensus.py <dump> [--kind constant] [--pairs] [--spans PFX,CT]
         vcensus.py --selfcheck

Prints the (value-encoding-prefix, vpiConstType) cross-tab.  Dump must already
have uhdm-dump's first line (the database path) stripped.
"""
import re
import sys
from collections import Counter

OBJ = re.compile(r'^( *)\\_(\w+): ?(.*)$')
FLD = re.compile(r'^( *)\|(\w+):(.*)$')
VK = {'INT', 'UINT', 'BIN', 'HEX', 'OCT', 'DEC', 'STRING', 'REAL', 'SCAL',
      'TIME'}


def scan(lines, kind='constant'):
    """Yield (span, fields, vpfx, vtxt) using an explicit open-object stack."""
    # stack entries: (indent, kind, span, fields{}, vpfx, vtxt) as a list so it
    # is mutable in place.
    stack = []
    out = []

    def close_to(ind):
        while stack and stack[-1][0] >= ind:
            e = stack.pop()
            if e[1] == kind:
                out.append((e[2], e[3], e[4], e[5]))

    for ln in lines:
        if not ln.strip():
            continue
        om = OBJ.match(ln)
        if om:
            ind = len(om.group(1))
            close_to(ind)
            rest = om.group(3)
            sm = re.search(r'line:(\d+):(\d+), endln:(\d+):(\d+)', rest)
            span = ('%s:%s-%s:%s' % sm.groups()) if sm else 'NOLOC'
            stack.append([ind, om.group(2), span, {}, None, None])
            continue
        fm = FLD.match(ln)
        if fm:
            ind = len(fm.group(1))
            close_to(ind)          # a field at indent I closes objects at >= I
            if not stack:
                continue
            e = stack[-1]
            if ind != e[0] + 2:    # not an own child of the open object
                continue
            k, v = fm.group(2), fm.group(3)
            if k in VK:
                if e[4] is None:
                    e[4], e[5] = k, v
            elif k not in e[3]:
                e[3][k] = v
            continue
    close_to(0)
    while stack:
        e = stack.pop()
        if e[1] == kind:
            out.append((e[2], e[3], e[4], e[5]))
    return out


SELF = '''\\_module_inst: (work@m)
  |vpiParent:
  \\_design: (work)
  |vpiLhs:
  \\_constant: , line:59:23, endln:59:27
    |vpiParent:
    \\_param_assign: , line:59:18, endln:59:29
    |vpiDecompile:1
    |vpiSize:3
    |INT:1
    |vpiTypespec:
    \\_ref_typespec: (work@m)
      |vpiParent:
      \\_constant: , line:59:23, endln:59:27
      |vpiFullName:work@m
      |vpiActual:
      \\_int_typespec: , line:59:14, endln:59:17
        |vpiSize:32
        |vpiConstType:99
    |vpiConstType:7
  |vpiTop:1
'''


def selfcheck():
    got = scan(SELF.split('\n'))
    # The ref_typespec's nested constant HEADER is a back-reference and carries
    # no own fields; it must be reported as a bare span with no fields, and the
    # real constant must carry ct=7 read from AFTER the nested subtree, with the
    # int_typespec's vpiConstType:99 NOT leaking in.
    real = [g for g in got if g[1] or g[2]]
    ok = (len(real) == 1 and real[0][1].get('vpiConstType') == '7'
          and real[0][2] == 'INT' and real[0][3] == '1'
          and real[0][1].get('vpiSize') == '3'
          and '99' not in real[0][1].values())
    print('SELFCHECK read:', real)
    print('SELFCHECK back-ref constant headers seen:', len(got) - len(real))
    print('SELFCHECK:', 'PASS' if ok else 'FAIL')
    return 0 if ok else 1


def main():
    if '--selfcheck' in sys.argv:
        sys.exit(selfcheck())
    path = sys.argv[1]
    kind = 'constant'
    if '--kind' in sys.argv:
        kind = sys.argv[sys.argv.index('--kind') + 1]
    lines = open(path, errors='replace').read().split('\n')
    objs = scan(lines, kind)
    cross = Counter()
    n = 0
    for span, f, vp, vt in objs:
        if not f and vp is None:
            continue           # a bare back-reference header
        n += 1
        cross[(vp or 'NOVAL', f.get('vpiConstType', 'NONE'))] += 1
    if '--spans' in sys.argv:
        want = sys.argv[sys.argv.index('--spans') + 1].split(',')
        for span, f, vp, vt in objs:
            if not f and vp is None:
                continue
            if (vp or 'NOVAL') == want[0] and f.get('vpiConstType',
                                                    'NONE') == want[1]:
                print('SPAN %-24s ct=%-4s sz=%-4s dc=%-12s %s:%s' % (
                    span, f.get('vpiConstType', 'NONE'),
                    f.get('vpiSize', '-'), f.get('vpiDecompile', '-'),
                    vp, vt))
        return
    if '--pairs' in sys.argv:
        for span, f, vp, vt in objs:
            if not f and vp is None:
                continue
            print('%s\t%s\t%s\t%s\t%s\t%s' % (
                span, vp or 'NOVAL', vt, f.get('vpiConstType', 'NONE'),
                f.get('vpiSize', '-'), f.get('vpiDecompile', '-')))
        return
    print('%-9s %-6s %s' % ('VALUE', 'ct', 'count'))
    for k in sorted(cross, key=lambda x: (x[0], x[1])):
        print('%-9s %-6s %d' % (k[0] + ':', k[1], cross[k]))
    print('TOTAL constants(%s) = %d' % (kind, n))


if __name__ == '__main__':
    main()
