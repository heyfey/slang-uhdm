#!/usr/bin/env python3
"""r10earl44 census — PORT vpiHighConn ACTUALS, BOTH SIDES, SPAN-KEYED,
SECTION-SEPARATED, and compared FIELD BY FIELD rather than by KIND.

LHS is ALWAYS golden (Surelog).  RHS is ALWAYS ours.

    usage: census44.py <g.dump> <o.dump>

Both dumps must already have uhdm-dump's first line (the database path)
stripped (`sed 1d`).

WHY IT IS NOT census43.py.  r10earl43's Q2 tallied golden-KIND -> ours-KIND and
its whole answer ("exactly ONE divergent port connection in the design") was
true only of the KIND.  The r10earl44 head is `ref_obj -> ref_obj`: it sits ON
THE DIAGONAL of that table and census43.py could not see it at all.  This
census keys every port high-conn actual on (section, scope, port name, port
span) exactly as census43.py does, and then compares the full descriptor:

    kind, span, vpiName, vpiFullName, presence+kind of vpiActual,
    presence+kind of vpiTypespec, kind of vpiParent

Q1  per-side kind tally (the census43 table, carried forward for continuity)
Q2  the span-keyed join, tallied golden-kind -> ours-kind
Q3  FIELD-LEVEL divergence on the common keys, tallied by DEFECT SIGNATURE
Q4  the QUALIFIED population: every actual whose vpiName carries `::`, per side
Q5  the constant SHAPE tally (parent kind x typespec), per side and section
Q6  the divergent cells, named, grouped by signature
"""
import re
import sys
from collections import defaultdict

OBJ = re.compile(r'^( *)(?:\\_)?([a-z_0-9]+): (.*)$')
FLD = re.compile(r'^( *)\|([A-Za-z_0-9]+):(.*)$')
SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')
FIELDS = ('vpiDecompile', 'vpiFullName', 'vpiName', 'vpiSize', 'vpiConstType',
          'vpiOpType')


def parse(path):
    section = None
    stack = []        # [indent, kind, span, name, pending_field, rec]
    conns = {}
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
                span = ('%s:%s-%s:%s' % sm.groups()) if sm else '?'
                nm = rest.split(',')[0].strip()
                if pfield == 'vpiParent':
                    # BACK-reference, never containment; but on a high-conn
                    # actual it is a datum the head turns on.
                    if parent is not None and parent[5] is not None \
                            and parent[5].get('is_hc'):
                        parent[5]['parent'] = (kind, span)
                    continue
                rec = None
                if parent is not None and pfield == 'vpiHighConn' \
                        and parent[1] == 'port':
                    scope = scopestack[-1][1] if scopestack else '?'
                    key = (section, scope, parent[3], parent[2])
                    rec = {'is_hc': True, 'key': key, 'kind': kind,
                           'span': span, 'nm': nm}
                    conns[key] = rec
                if parent is not None and parent[5] is not None \
                        and parent[5].get('is_hc'):
                    p = parent[5].pop('pend', None)
                    if p == 'ts':
                        parent[5]['ts'] = (kind, nm)
                    elif p == 'act':
                        parent[5]['act'] = (kind, nm, span)
                stack.append([ind, kind, span, nm, None, rec])
                if kind in ('module_inst', 'package', 'interface_inst'):
                    scopestack.append((ind, nm))
    return conns


def desc(r):
    if r is None:
        return '<absent>'
    f = r.get('f', {})
    a = r.get('act')
    return ('%s @%s name=%s full=%s dec=%s act->%s ts->%s par=%s'
            % (r['kind'], r['span'], f.get('vpiName', '-'),
               f.get('vpiFullName', '-'), f.get('vpiDecompile', '-'),
               ('%s(%s)@%s' % a) if a else '-',
               ('%s(%s)' % r['ts']) if r.get('ts') else '-',
               (r.get('parent') or ('-', ''))[0]))


def sig(a, b):
    """The DEFECT SIGNATURE of a common key: which fields differ."""
    f, g = a.get('f', {}), b.get('f', {})
    bits = []
    if a['kind'] != b['kind']:
        bits.append('KIND:%s->%s' % (a['kind'], b['kind']))
    if a['span'] != b['span']:
        bits.append('SPAN')
    if f.get('vpiName', '') != g.get('vpiName', ''):
        qa = '::' in f.get('vpiName', '')
        qb = '::' in g.get('vpiName', '')
        bits.append('NAME%s' % ('(G-qualified)' if qa and not qb
                                else '(O-qualified)' if qb and not qa else ''))
    if f.get('vpiFullName', '') != g.get('vpiFullName', ''):
        bits.append('FULLNAME%s' % ('(G-none)' if 'vpiFullName' not in f
                                    else '(O-none)' if 'vpiFullName' not in g
                                    else ''))
    if bool(a.get('act')) != bool(b.get('act')):
        bits.append('ACTUAL(%s)' % ('G-only' if a.get('act') else 'O-only'))
    elif a.get('act') and b.get('act') and a['act'][0] != b['act'][0]:
        bits.append('ACTUALKIND')
    if bool(a.get('ts')) != bool(b.get('ts')):
        bits.append('TS(%s)' % ('G-only' if a.get('ts') else 'O-only'))
    if (a.get('parent') or ('-',))[0] != (b.get('parent') or ('-',))[0]:
        bits.append('PARENT(%s->%s)' % ((a.get('parent') or ('-',))[0],
                                        (b.get('parent') or ('-',))[0]))
    if f.get('vpiDecompile') != g.get('vpiDecompile'):
        bits.append('DECOMPILE')
    return ' '.join(bits)


def main():
    gc = parse(sys.argv[1])
    oc = parse(sys.argv[2])

    print('Q1  port vpiHighConn actuals: golden %d  ours %d' % (len(gc), len(oc)))
    for label, c in (('golden', gc), ('ours', oc)):
        t = defaultdict(int)
        for r in c.values():
            t[(r['key'][0], r['kind'])] += 1
        print('  %s:' % label)
        for k in sorted(t):
            print('    %-14s %-24s %d' % (k[0], k[1], t[k]))

    both = set(gc) & set(oc)
    gonly = sorted(set(gc) - set(oc))
    oonly = sorted(set(oc) - set(gc))
    print()
    print('Q2  JOIN on (section, scope, port name, port span): common %d  '
          'golden-only %d  ours-only %d' % (len(both), len(gonly), len(oonly)))
    t = defaultdict(int)
    for k in both:
        t[(gc[k]['kind'], oc[k]['kind'])] += 1
    for k in sorted(t):
        mark = '' if k[0] == k[1] else '   <-- KIND-DIVERGENT'
        print('    golden %-22s -> ours %-22s %6d%s' % (k[0], k[1], t[k], mark))

    print()
    print('Q3  FIELD-LEVEL divergence on the %d common keys' % len(both))
    fam = defaultdict(list)
    for k in both:
        s = sig(gc[k], oc[k])
        if s:
            fam[s].append(k)
    tot = sum(len(v) for v in fam.values())
    print('    cells with ANY field divergence: %d' % tot)
    for s in sorted(fam, key=lambda x: -len(fam[x])):
        print('    %6d  %s' % (len(fam[s]), s))

    print()
    print('Q4  QUALIFIED (`::`) vpiName population among high-conn actuals')
    for label, c in (('golden', gc), ('ours', oc)):
        t = defaultdict(int)
        for r in c.values():
            if '::' in r.get('f', {}).get('vpiName', ''):
                t[(r['key'][0], r['kind'],
                   'full' if 'vpiFullName' in r.get('f', {}) else 'nofull',
                   'act' if r.get('act') else 'noact')] += 1
        print('  %s: %d' % (label, sum(t.values())))
        for k in sorted(t):
            print('    %-14s %-12s %-7s %-6s %d' % (k[0], k[1], k[2], k[3], t[k]))

    print()
    print('Q5  constant high-conn SHAPE tally (parent kind x typespec)')
    for label, c in (('golden', gc), ('ours', oc)):
        t = defaultdict(int)
        for r in c.values():
            if r['kind'] == 'constant':
                t[(r['key'][0], (r.get('parent') or ('<none>', ''))[0],
                   bool(r.get('ts')))] += 1
        print('  %s:' % label)
        for k in sorted(t):
            print('    %-14s parent=%-16s typespec=%-5s %d' % (k[0], k[1], k[2], t[k]))

    print()
    print('Q6  THE DIVERGENT CELLS, named, by signature')
    for s in sorted(fam, key=lambda x: -len(fam[x])):
        print('  --- %s : %d' % (s, len(fam[s])))
        for k in sorted(fam[s])[:60]:
            print('    %-12s %-56s port %-24s @%s' % (k[0], k[1], k[2], k[3]))
            print('        G: %s' % desc(gc[k]))
            print('        O: %s' % desc(oc[k]))

    print()
    print('Q7  GOLDEN-ONLY keys %d, OURS-ONLY keys %d' % (len(gonly), len(oonly)))
    for k in gonly[:30]:
        print('    G-ONLY %-12s %-52s port %-22s @%s -> %s'
              % (k[0], k[1], k[2], k[3], desc(gc[k])))
    for k in oonly[:30]:
        print('    O-ONLY %-12s %-52s port %-22s @%s -> %s'
              % (k[0], k[1], k[2], k[3], desc(oc[k])))


main()
