#!/usr/bin/env python3
"""r11u52v — TRUNCATED-OPERATION scanner.

The law's per-reference copy of a symbolic element bound is built by a
hand-rolled cloner that models three UHDM kinds (constant / ref_obj /
operation).  Before the verifier fix it DROPPED any operand it could not model,
leaving a BINARY operation carrying ONE operand — a malformed expression.  This
scanner reads a uhdm-dump text and reports every operation whose operand count
differs from the count of the SAME operation (same vpiOpType, same source span)
elsewhere in the same dump, plus every binary-opType operation with exactly one
operand.

usage: opscan.py <dump> [<dump> ...]
"""
import re
import sys
from collections import defaultdict

OBJ = re.compile(r'^(\s*)\\_(\w+):\s*(\([^)]*\))?,?\s*(.*)$')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')
LOC = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')
# vpiOpType values that MUST carry two or more operands
BINARY = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
          21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37,
          38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50}
# ... minus the unary ones we actually see on range bounds
UNARY = {32, 33, 34, 35, 36, 37, 38, 39, 40}


def scan(path):
    lines = open(path, errors='replace').read().split('\n')
    # for every operation object line, walk forward collecting the fields that
    # belong to it (indent == its own indent) until an object at a shallower or
    # equal indent closes it.
    out = []
    for i, ln in enumerate(lines):
        m = OBJ.match(ln)
        if not m or m.group(2) != 'operation':
            continue
        ind = len(m.group(1))
        loc = LOC.search(m.group(4) or '')
        span = '%s:%s-%s:%s' % loc.groups() if loc else '?'
        ops = 0
        opty = None
        j = i + 1
        while j < len(lines):
            mo = OBJ.match(lines[j])
            mf = FLD.match(lines[j])
            if mo and len(mo.group(1)) <= ind:
                break
            if mf and len(mf.group(1)) == ind + 2:
                if mf.group(2) == 'vpiOperand':
                    ops += 1
                elif mf.group(2) == 'vpiOpType':
                    opty = int(mf.group(3))
            elif mf and len(mf.group(1)) <= ind:
                break
            j += 1
        out.append((span, opty, ops))
    return out


def report(path):
    objs = scan(path)
    by = defaultdict(set)
    for span, opty, n in objs:
        by[(span, opty)].add(n)
    bad_unequal = {k: sorted(v) for k, v in by.items() if len(v) > 1}
    bad_single = sorted({(s, o) for s, o, n in objs
                         if n == 1 and o is not None and o not in UNARY})
    print('%s: operations=%d' % (path, len(objs)))
    print('  SPAN+OPTYPE with DIFFERING operand counts (a truncated copy): %d'
          % len(bad_unequal))
    for k, v in sorted(bad_unequal.items()):
        print('    span=%s opType=%s counts=%s' % (k[0], k[1], v))
    print('  BINARY-opType operations carrying ONE operand: %d' %
          len(bad_single))
    for s, o in bad_single:
        print('    span=%s opType=%s' % (s, o))


if __name__ == '__main__':
    for p in sys.argv[1:]:
        report(p)
