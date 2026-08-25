#!/usr/bin/env python3
"""v132 INDEPENDENT scorer (measurement only; uhdm-cmp is the judge).

Multiset census over a uhdm-dump text keyed on KIND | NAME | SPAN only.
- drops back-reference stubs (an object line whose introducing field was vpiParent)
- folds continuation lines (a NAME containing a newline, which the pristine
  emits for a misread receiver) into the previous line
- restricted by default to the kinds this law can touch.
usage: vscore132.py <dump> [--all]
       vscore132.py -c <gold> <ours> [--all]
"""
import re, sys
from collections import Counter

OBJ = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?, ?(.*)$')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')
KINDS = {'hier_path', 'ref_obj', 'method_func_call', 'func_call', 'tf_call',
         'var_select', 'bit_select', 'operation', 'sys_func_call'}

def parse(path, allkinds=False):
    raw = open(path, errors='replace').read().split('\n')
    lines = []
    for ln in raw:
        if OBJ.match(ln) or FLD.match(ln) or not lines:
            lines.append(ln)
        else:
            lines[-1] = lines[-1] + ' ' + ln.strip()
    c = Counter()
    cur_field = None
    for ln in lines:
        m = OBJ.match(ln)
        if m:
            kind, name, rest = m.group(2), m.group(3) or '', m.group(4)
            stub = (cur_field == 'vpiParent')
            cur_field = None
            if stub:
                continue
            sm = re.search(r'line:(\d+:\d+), endln:(\d+:\d+)', rest)
            span = (sm.group(1) + '-' + sm.group(2)) if sm else ''
            if allkinds or kind in KINDS:
                c['%s|%s|%s' % (kind, name, span)] += 1
            continue
        f = FLD.match(ln)
        if f:
            cur_field = f.group(2)
    return c

if sys.argv[1] == '-c':
    allk = '--all' in sys.argv
    g = parse(sys.argv[2], allk); o = parse(sys.argv[3], allk)
    same = sum((g & o).values())
    og = g - o; oo = o - g
    print('SAME=%d ONLY-GOLDEN=%d ONLY-OURS=%d' % (same, sum(og.values()), sum(oo.values())))
    for k in sorted(og): print('  G %dx %s' % (og[k], k))
    for k in sorted(oo): print('  O %dx %s' % (oo[k], k))
else:
    allk = '--all' in sys.argv
    for k, n in sorted(parse(sys.argv[1], allk).items()): print('%dx %s' % (n, k))
