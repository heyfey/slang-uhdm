#!/usr/bin/env python3
"""r10earl44 GRID — every port's vpiHighConn actual, BOTH SIDES, keyed on the
INSTANCE (the port's vpiParent ref_module / module_inst) so a row survives span
drift.  LHS is ALWAYS golden.

    usage: grid44.py <g.dump> <o.dump>

Both dumps must already have uhdm-dump's first line (the DATABASE PATH, which
always differs) stripped — `sed 1d`.

WHY THIS IS NOT grid43.py.  r10earl43's cell() printed vpiDecompile ELSE
vpiFullName ELSE vpiName, i.e. exactly ONE of them.  The r10earl44 head is a
ref_obj that carries a QUALIFIED vpiName and NO vpiFullName where we carry a
BARE vpiName and a SYNTHESIZED vpiFullName — a cell grid43.py would have
printed as `ref_obj @span <ourfullname>` vs `ref_obj @span <goldenname>` and
which would have read as a NAMING residue rather than as the three separate
defects it is.  So this grid prints, ALWAYS and SEPARATELY:

    kind  @span  name=<vpiName>  full=<vpiFullName or ->  act-><actual kind>
          ts-><typespec kind>    par=<vpiParent kind>

`vpiActual` is a forward link printed like a child; `vpiParent` is a BACK
reference printed in exactly the same shape.  Neither is containment and both
are read explicitly, then skipped.
"""
import re
import sys

OBJ = re.compile(r'^( *)(?:\\_)?([a-z_0-9]+): (.*)$')
FLD = re.compile(r'^( *)\|([A-Za-z_0-9]+):(.*)$')
SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')
FIELDS = ('vpiDecompile', 'vpiFullName', 'vpiName', 'vpiSize', 'vpiConstType',
          'vpiOpType')


def parse(path, want='vpiHighConn'):
    section = None
    stack = []        # [indent, kind, span, name, pending_field, rec, inst]
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
                if r is not None and r.get('is_hc'):
                    if name in FIELDS:
                        r.setdefault('f', {})[name] = val.strip()
                    if name == 'vpiTypespec':
                        r['pend'] = 'ts'
                    if name == 'vpiActual':
                        r['pend'] = 'act'
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
                    inst = parent[6] if len(parent) > 6 else '?'
                    rec = {'is_hc': True, 'kind': kind, 'span': span, 'nm': nm,
                           'key': (section, inst, parent[3])}
                    out[rec['key']] = rec
                if parent is not None and parent[5] is not None \
                        and parent[5].get('is_hc'):
                    p = parent[5].pop('pend', None)
                    if p == 'ts':
                        parent[5]['ts'] = (kind, nm, span)
                    elif p == 'act':
                        parent[5]['act'] = (kind, nm, span)
                stack.append([ind, kind, span, nm, None, rec, '?'])
                if kind in ('module_inst', 'package', 'interface_inst'):
                    scopestack.append((ind, nm))
    return out


def cell(r):
    if r is None:
        return 'ABSENT'
    f = r.get('f', {})
    bits = ['%-9s' % r['kind'], '@' + r['span']]
    if 'vpiDecompile' in f:
        bits.append('dec=' + f['vpiDecompile'])
        if 'vpiSize' in f:
            bits.append('sz=' + f['vpiSize'])
    bits.append('name=' + f.get('vpiName', '-'))
    bits.append('full=' + f.get('vpiFullName', '-'))
    if 'vpiOpType' in f:
        bits.append('op' + f['vpiOpType'])
    a = r.get('act')
    bits.append('act->' + (('%s(%s)@%s' % a) if a else '-'))
    t = r.get('ts')
    bits.append('ts->' + (('%s(%s)' % (t[0], t[1] or '')) if t else '-'))
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
