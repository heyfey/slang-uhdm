#!/usr/bin/env python3
"""Project a uhdm-dump onto "every sys_func_call and the SHAPE of its argument".

usage: sysarg.py <dump> [<dump2>]

Prints one line per sys_func_call occurrence:
    <name> @L:C  arg=<kind>(<name>) @L:C [op=<n>]
deduplicated with an xN count, so the two views of one declaration collapse.
Also reports declaration-range positions where NO sys_func_call survives (the
call folded away) by listing every `constant` that sits where one used to.
"""
import re, sys, collections

DECL = re.compile(r'^(\s*)\\_(\w+): \(?([^)]*)\)?, line:(\d+):(\d+), endln:(\d+):(\d+)')


def parse(path):
    rows = []
    lines = open(path).read().splitlines()
    for i, ln in enumerate(lines):
        m = DECL.match(ln)
        if not m or m.group(2) != 'sys_func_call':
            continue
        ind = len(m.group(1))
        nm = m.group(3)
        loc = '%s:%s' % (m.group(4), m.group(5))
        # walk forward for vpiArgument: at ind+2
        arg = '<none>'
        j = i + 1
        while j < len(lines):
            l2 = lines[j]
            s2 = len(l2) - len(l2.lstrip())
            if s2 <= ind and l2.strip().startswith('\\_'):
                break
            if l2.strip() == '|vpiArgument:' and s2 == ind + 2:
                m3 = DECL.match(lines[j + 1])
                if m3:
                    arg = '%s(%s)@%s:%s' % (m3.group(2), m3.group(3),
                                            m3.group(4), m3.group(5))
                    # operation -> grab vpiOpType
                    if m3.group(2) == 'operation':
                        k = j + 2
                        while k < len(lines) and k < j + 12:
                            if lines[k].strip().startswith('|vpiOpType:'):
                                arg += ' op=' + lines[k].strip().split(':')[1]
                                break
                            k += 1
                    if m3.group(2) == 'constant':
                        k = j + 2
                        while k < len(lines) and k < j + 12:
                            if lines[k].strip().startswith('|vpiDecompile:'):
                                arg += ' dec=' + lines[k].strip().split(':', 1)[1]
                            if lines[k].strip().startswith('|vpiConstType:'):
                                arg += ' ct=' + lines[k].strip().split(':')[1]
                                break
                            k += 1
                break
            j += 1
        rows.append('%s @%s  arg=%s' % (nm, loc, arg))
    return rows


for p in sys.argv[1:]:
    print('==== %s' % p)
    c = collections.Counter(parse(p))
    for k in sorted(c, key=lambda x: (int(x.split('@')[1].split(':')[0]),
                                      int(x.split('@')[1].split(':')[1].split()[0]))):
        print('  x%-2d %s' % (c[k], k))
