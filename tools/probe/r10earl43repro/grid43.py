#!/usr/bin/env python3
"""r10earl43 GRID — every port's vpiHighConn actual, BOTH SIDES, keyed on the
INSTANCE (the port's vpiParent ref_module / module_inst) so a row survives span
drift.  LHS is ALWAYS golden.

    usage: grid43.py <g.dump> <o.dump>

Both dumps must already have uhdm-dump's first line (the DATABASE PATH, which
always differs) stripped — `sed 1d`.

WHAT IT READS.  uhdm-dump prints an object header at some indent, its FIELDS at
indent+2, and each field's CHILD OBJECTS also at indent+2 on the line after the
field name.  `|vpiParent:` is a BACK-reference printed in exactly the same shape
as a child: it must not be treated as containment.  On a port it is the ONE
datum that names the instance, and on a folded constant it is the datum the
Earlgrey head turns on, so both are read explicitly and then skipped.

It prints GOLDEN_ONLY / OURS_ONLY rows rather than dropping a row either side
lacks.
"""
import re
import sys
from collections import defaultdict

OBJ = re.compile(r'^( *)(?:\\_)?([a-z_0-9]+): (.*)$')
FLD = re.compile(r'^( *)\|([A-Za-z_0-9]+):(.*)$')
SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')
FIELDS = ('vpiDecompile', 'vpiFullName', 'vpiName', 'vpiSize', 'vpiConstType',
          'vpiOpType')


def parse(path, want='vpiHighConn'):
    section = None
    stack = []        # [indent, kind, span, name, pending_field, rec]
    out = {}
    scopestack = []

    def close_to(ind):
        while stack and stack[-1][0] >= ind:
            stack.pop()
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
                if r is not None and r.get('is_hc') and name in FIELDS:
                    r.setdefault('f', {})[name] = val.strip()
                if r is not None and r.get('is_hc') and name == 'vpiTypespec':
                    r['tsnext'] = True
                continue
            m = OBJ.match(line)
            if m:
                ind, kind, rest = len(m.group(1)), m.group(2), m.group(3)
                close_to(ind)
                parent = stack[-1] if stack else None
                pfield = parent[4] if parent else None
                sm = SPAN.search(rest)
                span = ('%s:%s-%s:%s' % sm.groups()) if sm else '-'
                nm = rest.split(',')[0].strip()
                if pfield == 'vpiParent':
                    if parent is not None:
                        if parent[1] == 'port':
                            parent[6] = nm          # the INSTANCE
                        if parent[5] is not None and parent[5].get('is_hc'):
                            parent[5]['parent'] = (kind, span)
                    continue
                rec = None
                if parent is not None and pfield == want \
                        and parent[1] == 'port':
                    scope = scopestack[-1][1] if scopestack else '?'
                    inst = parent[6] if len(parent) > 6 else '?'
                    rec = {'is_hc': True, 'kind': kind, 'span': span, 'nm': nm,
                           'key': (section, inst, parent[3])}
                    out[rec['key']] = rec
                if parent is not None and parent[5] is not None \
                        and parent[5].get('is_hc') and parent[5].pop('tsnext', None):
                    parent[5]['ts'] = (kind, nm, span)
                stack.append([ind, kind, span, nm, None, rec, '?'])
                if kind in ('module_inst', 'package', 'interface_inst'):
                    scopestack.append((ind, nm))
    return out


def cell(r):
    if r is None:
        return 'ABSENT'
    f = r.get('f', {})
    bits = [r['kind'], '@' + r['span']]
    if 'vpiDecompile' in f:
        bits.append(f['vpiDecompile'])
    elif 'vpiFullName' in f:
        bits.append(f['vpiFullName'])
    elif 'vpiName' in f:
        bits.append(f['vpiName'])
    if 'vpiOpType' in f:
        bits.append('op' + f['vpiOpType'])
    if r.get('ts'):
        bits.append('ts->' + r['ts'][0] + '(' + (r['ts'][1] or '') + ')')
    else:
        bits.append('ts:-')
    bits.append('par=' + (r.get('parent') or ('-', ''))[0])
    return ' '.join(bits)


def main():
    g = parse(sys.argv[1])
    o = parse(sys.argv[2])
    keys = sorted(set(g) | set(o))
    nd = 0
    for k in keys:
        a, b = g.get(k), o.get(k)
        ca, cb = cell(a), cell(b)
        if a is None:
            verd = 'OURS_ONLY'
        elif b is None:
            verd = 'GOLDEN_ONLY'
        elif ca == cb:
            verd = 'MATCH'
        else:
            verd = 'DIFFER'
        if verd != 'MATCH':
            nd += 1
        print('%-11s %-11s %-46s %-14s' % (verd, k[0], k[1], k[2]))
        print('      G: %s' % ca)
        print('      O: %s' % cb)
    print()
    print('ROWS %d   NON-MATCH %d' % (len(keys), nd))


main()
