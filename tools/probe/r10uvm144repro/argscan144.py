#!/usr/bin/env python3
# r10uvm144 -- CALL-ARGUMENT BINDING CENSUS out of a `uhdm-dump`.
#
# For every tf_call / method call in the dump, emit one row per ARGUMENT that is
# a `ref_obj`:
#     <callkind> <scoped?> <callname> <refname> <line>:<col> <actual-kind> <actual-name>
# Keys are read from the object's OWN fields (|vpiName, line:col) and from the
# ACTUAL's UHDM KIND -- never from the dump-synthesized vpiFullName, which is
# built from the parent chain and differs between the two producers for reasons
# uhdm-cmp does not read.
#
# MEASUREMENT ONLY -- the judge is the official uhdm-cmp.
#   usage: argscan144.py <dump> [full]
import sys, re
from collections import Counter

CALLK = ('func_call', 'task_call', 'method_func_call', 'method_task_call',
         'sys_func_call', 'sys_task_call')

def ind(s):
    return len(s) - len(s.lstrip(' '))

def scan(path):
    lines = open(path, errors='replace').read().split('\n')
    n = len(lines)
    rows = []
    for i, l in enumerate(lines):
        m = re.match(r'\s*\\_(\w+): ', l)
        if not m or m.group(1) not in CALLK:
            continue
        kind = m.group(1)
        base = ind(l)
        cname = ''
        j = i + 1
        args = []
        while j < n:
            cj = lines[j]
            if not cj.strip() or ind(cj) <= base:
                break
            if ind(cj) == base + 2:
                st = cj.strip()
                if st.startswith('|vpiName:'):
                    cname = st[9:]
                elif st == '|vpiArgument:':
                    ma = re.match(r'\s*\\_(\w+): .*?line:(\d+):(\d+)', lines[j + 1])
                    if ma and ma.group(1) == 'ref_obj':
                        ab = ind(lines[j + 1])
                        rname = ''
                        act, aname = 'NONE', ''
                        t = j + 2
                        while t < n and lines[t].strip() and ind(lines[t]) > ab:
                            if ind(lines[t]) == ab + 2:
                                s2 = lines[t].strip()
                                if s2.startswith('|vpiName:'):
                                    rname = s2[9:]
                                elif s2 == '|vpiActual:':
                                    mm = re.match(r'\s*\\_(\w+): (?:\(([^)]*)\))?',
                                                  lines[t + 1])
                                    if mm:
                                        act = mm.group(1)
                                        t2 = t + 2
                                        ab2 = ind(lines[t + 1])
                                        while (t2 < n and lines[t2].strip()
                                               and ind(lines[t2]) > ab2):
                                            if (ind(lines[t2]) == ab2 + 2 and
                                                    lines[t2].strip().startswith('|vpiName:')):
                                                aname = lines[t2].strip()[9:]
                                                break
                                            t2 += 1
                            t += 1
                        args.append((rname, ma.group(2) + ':' + ma.group(3),
                                     act, aname))
            j += 1
        for a in args:
            rows.append((kind, 'SCOPED' if '::' in cname else 'PLAIN', cname) + a)
    return rows

def main():
    rows = scan(sys.argv[1])
    c = Counter((r[0], r[1], r[5]) for r in rows)
    print('total\t%d' % len(rows))
    for k, v in sorted(c.items()):
        print('COUNT\t%s\t%s\t%s\t%d' % (k[0], k[1], k[2], v))
    if len(sys.argv) > 2:
        for r in rows:
            print('ROW\t' + '\t'.join(r))

main()
