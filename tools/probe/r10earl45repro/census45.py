#!/usr/bin/env python3
"""r10earl45 census — OPERATION vpiSize, BOTH SIDES, DESIGN-WIDE, SPAN-KEYED,
SECTION-SEPARATED, and keyed additionally on PATTERN NESTING DEPTH.

LHS is ALWAYS golden (Surelog).  RHS is ALWAYS ours.

    usage: census45.py <g.dump> <o.dump>

Both dumps must already have uhdm-dump's first line (the database path)
stripped (`sed 1d`).

WHY IT IS NOT census44.py.  census44 keyed PORT vpiHighConn actuals.  The
r10earl45 head is an `operation` in a localparam's assignment-pattern nest and
the ONLY cmp-visible field on it is `vpiSize` (expr::Compare compares
VpiDecompile, VpiSize and Typespec; BaseClass::Compare compares VpiType,
VpiName, VpiDefName; NOTHING in UHDM's 233 generated Compare bodies reads
VpiParent).  So this census tallies EVERY operation object in the design, both
sides, keyed on (section, scope path, span, opType, ordinal), and compares:

    presence + value of vpiSize, and the PATTERN NESTING DEPTH of the op
    (0 = an op75 that is not inside another op75; 1 = its direct child; ...)

Q1  per-side operation tally by (section, opType, has-size)
Q2  span-keyed join: golden size -> ours size, tallied by opType
Q3  op75 (assignment pattern) cells ONLY, tallied by (depth, golden, ours)
Q4  the DIVERGENT op75 cells, named (scope, span, depth, sizes)
Q5  every divergent operation of ANY opType, tallied by signature
"""
import re
import sys
from collections import defaultdict

OBJ = re.compile(r'^( *)(?:\\_)?([a-z_0-9]+): (.*)$')
FLD = re.compile(r'^( *)\|([A-Za-z_0-9]+):(.*)$')
SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')
SCOPEKINDS = ('module_inst', 'package', 'interface_inst', 'gen_scope',
              'gen_scope_array', 'class_defn')
BACKREF = ('vpiParent', 'vpiActual', 'vpiInstance', 'vpiModule', 'vpiTypedef',
           'vpiTaskFunc', 'vpiVariables_')


def parse(path):
    """Return {key: rec} for every operation object, plus the raw op list."""
    section = None
    stack = []       # [indent, kind, span, name, pending_field, rec]
    scopestack = []
    ops = {}
    counts = defaultdict(int)

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
                # A field line sits at the SAME indent as its owner's CHILDREN
                # (owner indent + 2), so it closes exactly what a child object
                # at that indent closes.  Using `ind + 1` here leaves the
                # previous sibling on the stack and files the field on the
                # WRONG object — measured: it filed `|vpiOpType:75` on the
                # preceding `ref_typespec` and reported every nested pattern op
                # at depth 0.
                ind, name, val = len(m.group(1)), m.group(2), m.group(3)
                close_to(ind)
                if not stack:
                    continue
                owner = stack[-1]
                owner[4] = name
                r = owner[5]
                if r is not None:
                    if name == 'vpiSize':
                        r['size'] = val.strip()
                    elif name == 'vpiOpType':
                        r['optype'] = val.strip()
                    elif name == 'vpiReordered':
                        r['reord'] = val.strip()
                continue
            m = OBJ.match(line)
            if m:
                ind, kind, rest = len(m.group(1)), m.group(2), m.group(3)
                close_to(ind)
                parent = stack[-1] if stack else None
                pfield = parent[4] if parent else None
                if pfield in BACKREF:
                    # a BACK-reference print, never containment
                    continue
                sm = SPAN.search(rest)
                span = ('%s:%s-%s:%s' % sm.groups()) if sm else '?'
                nm = rest.split(',')[0].strip()
                rec = None
                if kind == 'operation':
                    # pattern nesting depth: count enclosing op75 frames
                    depth = 0
                    for fr in stack:
                        if fr[5] is not None and fr[5].get('optype') == '75':
                            depth += 1
                    scope = '/'.join(s[1] for s in scopestack) or '?'
                    base = (section, scope, span)
                    counts[base] += 1
                    key = base + (counts[base],)
                    rec = {'key': key, 'span': span, 'scope': scope,
                           'section': section, 'depth': depth,
                           'optype': None, 'size': None, 'reord': None,
                           'ownerfield': pfield,
                           'ownerkind': parent[1] if parent else None,
                           'ownername': parent[3] if parent else None}
                    ops[key] = rec
                stack.append([ind, kind, span, nm, None, rec])
                if kind in SCOPEKINDS:
                    scopestack.append((ind, nm))
    return ops


def main():
    g = parse(sys.argv[1])
    o = parse(sys.argv[2])
    print('Q1  operation objects: golden %d   ours %d' % (len(g), len(o)))

    t = defaultdict(int)
    for side, d in (('G', g), ('O', o)):
        for r in d.values():
            t[(side, r['section'], r['optype'], r['size'] is not None)] += 1
    print('\nQ1b per-side tally (section, opType, has-size) -- top 40')
    for k, v in sorted(t.items(), key=lambda kv: -kv[1])[:40]:
        print('   %-2s %-12s opType=%-5s hassize=%-5s  %d' %
              (k[0], k[1], k[2], k[3], v))

    common = set(g) & set(o)
    print('\nQ2  SPAN-KEYED JOIN: common %d  golden-only %d  ours-only %d' %
          (len(common), len(set(g) - set(o)), len(set(o) - set(g))))
    j = defaultdict(int)
    for k in common:
        gr, orr = g[k], o[k]
        j[(gr['optype'], gr['size'], orr['size'])] += 1
    print('    opType   goldenSize  oursSize   cells   (only rows that DIFFER'
          ' are marked <<<)')
    for k, v in sorted(j.items(), key=lambda kv: -kv[1]):
        mark = ' <<<' if k[1] != k[2] else ''
        print('    %-8s %-11s %-10s %6d%s' % (k[0], k[1], k[2], v, mark))

    print('\nQ3  op75 (assignment pattern) cells ONLY, by (depth, gSize, oSize)')
    p = defaultdict(int)
    for k in common:
        gr, orr = g[k], o[k]
        if gr['optype'] == '75' or orr['optype'] == '75':
            p[(gr['depth'], gr['size'], orr['size'])] += 1
    for k, v in sorted(p.items(), key=lambda kv: (kv[0][0], str(kv[0][1]),
                                                  str(kv[0][2]))):
        mark = ' <<<' if k[1] != k[2] else ''
        print('    depth=%-3s gSize=%-8s oSize=%-8s  %6d%s' %
              (k[0], k[1], k[2], v, mark))

    print('\nQ4  DIVERGENT op75 cells, named (up to 60)')
    bad = [k for k in common
           if (g[k]['optype'] == '75' or o[k]['optype'] == '75')
           and g[k]['size'] != o[k]['size']]
    byfile = defaultdict(int)
    for k in bad:
        byfile[(g[k]['section'], g[k]['depth'], g[k]['size'], o[k]['size'])] += 1
    for k, v in sorted(byfile.items(), key=lambda kv: -kv[1]):
        print('    %-12s depth=%s  g=%s  o=%s   %d cells' % (k[0], k[1], k[2],
                                                             k[3], v))
    for k in sorted(bad)[:60]:
        print('    %-12s %-46s %-16s depth=%s g=%s o=%s owner=%s.%s' %
              (g[k]['section'], g[k]['scope'][-46:], g[k]['span'],
               g[k]['depth'], g[k]['size'], o[k]['size'],
               g[k]['ownerkind'], g[k]['ownerfield']))
    print('    TOTAL divergent op75 cells: %d' % len(bad))

    print('\nQ5  DIVERGENT operations of ANY opType, by signature')
    sig = defaultdict(int)
    for k in common:
        gr, orr = g[k], o[k]
        if gr['size'] != orr['size'] or gr['optype'] != orr['optype'] \
                or gr['reord'] != orr['reord']:
            s = []
            if gr['optype'] != orr['optype']:
                s.append('OPTYPE(%s->%s)' % (gr['optype'], orr['optype']))
            if gr['size'] != orr['size']:
                s.append('SIZE(%s->%s)' % (gr['size'], orr['size']))
            if gr['reord'] != orr['reord']:
                s.append('REORD(%s->%s)' % (gr['reord'], orr['reord']))
            sig[(gr['section'], gr['optype'], ' '.join(s))] += 1
    tot = 0
    for k, v in sorted(sig.items(), key=lambda kv: -kv[1])[:40]:
        print('    %-12s opType=%-5s %-40s %6d' % (k[0], k[1], k[2], v))
        tot += v
    print('    TOTAL divergent operation cells (all opTypes): %d' %
          sum(sig.values()))


if __name__ == '__main__':
    main()
