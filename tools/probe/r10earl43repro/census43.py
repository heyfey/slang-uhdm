#!/usr/bin/env python3
"""r10earl43 census — PORT vpiHighConn ACTUALS, BOTH SIDES, SPAN-KEYED,
SECTION-SEPARATED.

LHS is ALWAYS golden (Surelog).  RHS is ALWAYS ours.

    usage: census43.py <g.dump> <o.dump>

Both dumps must already have uhdm-dump's first line (the database path)
stripped (`sed 1d`).

WHAT IT READS.  uhdm-dump prints an object header at some indent, then its
FIELDS at indent+2, and each field's CHILD OBJECTS also at indent+2 on the line
following the field name.  `|vpiParent:` is a BACK-reference printed in exactly
the same shape as a child, so the parser must not treat it as containment — it
is skipped by name.  Sections are the `|uhdm<x>:` lines at indent 0.

WHAT IT REPORTS.
  Q1  every port's vpiHighConn child, keyed (section, scope, port name, port
      span) -> (child kind, child span, child name/decompile), per side.
  Q2  the join tallied golden-kind -> ours-kind.
  Q3  the divergent cells, named.
  Q4  golden's folded-constant high conns: how many carry a vpiTypespec and a
      param_assign vpiParent (the head's shape).
"""
import re
import sys
from collections import defaultdict

OBJ = re.compile(r'^( *)(?:\\_)?([a-z_0-9]+): (.*)$')
FLD = re.compile(r'^( *)\|([A-Za-z_0-9]+):(.*)$')
SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')


def parse(path):
    section = None
    stack = []        # [indent, kind, span, name, pending_field, rec]
    conns = {}        # key -> record
    scopestack = []   # (indent, name)

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
                # record fields ON the high-conn actual itself
                if owner[5] is not None and owner[5].get('is_hc'):
                    r = owner[5]
                    if name in ('vpiDecompile', 'vpiFullName', 'vpiName',
                                'vpiSize', 'vpiConstType'):
                        r.setdefault('f', {})[name] = val.strip()
                    if name == 'vpiTypespec':
                        r['ts'] = True
                    if name == 'vpiActual':
                        r['hasactual'] = True
                continue
            m = OBJ.match(line)
            if m:
                ind, kind, rest = len(m.group(1)), m.group(2), m.group(3)
                close_to(ind)
                parent = stack[-1] if stack else None
                pfield = parent[4] if parent else None
                if pfield == 'vpiParent':
                    # BACK-reference; but on a high-conn actual it is the ONE
                    # datum the head turns on, so record it before skipping.
                    if parent is not None and parent[5] is not None \
                            and parent[5].get('is_hc'):
                        sm2 = SPAN.search(rest)
                        parent[5]['parent'] = (
                            kind, ('%s:%s-%s:%s' % sm2.groups()) if sm2 else '?')
                    continue
                sm = SPAN.search(rest)
                span = ('%s:%s-%s:%s' % sm.groups()) if sm else '?'
                nm = rest.split(',')[0].strip()
                rec = None
                if parent is not None and pfield == 'vpiHighConn' \
                        and parent[1] == 'port':
                    scope = scopestack[-1][1] if scopestack else '?'
                    key = (section, scope, parent[3], parent[2])
                    rec = {'is_hc': True, 'key': key, 'kind': kind,
                           'span': span, 'nm': nm}
                    conns[key] = rec
                stack.append([ind, kind, span, nm, None, rec])
                if kind in ('module_inst', 'package', 'interface_inst'):
                    scopestack.append((ind, nm))
    return conns


def desc(r):
    if r is None:
        return '<absent>'
    f = r.get('f', {})
    extra = f.get('vpiDecompile') or f.get('vpiFullName') or f.get('vpiName') or ''
    return '%s @%s %s' % (r['kind'], r['span'], extra)


def main():
    g, o = sys.argv[1], sys.argv[2]
    gc = parse(g)
    oc = parse(o)

    print('Q1  port vpiHighConn actuals: golden %d  ours %d' % (len(gc), len(oc)))
    for label, c in (('golden', gc), ('ours', oc)):
        t = defaultdict(int)
        for r in c.values():
            t[(r['key'][0], r['kind'])] += 1
        print('  %s:' % label)
        for k in sorted(t):
            print('    %-14s %-24s %d' % (k[0], k[1], t[k]))

    print()
    both = set(gc) & set(oc)
    gonly = sorted(set(gc) - set(oc))
    oonly = sorted(set(oc) - set(gc))
    print('Q2  JOIN on (section, scope, port name, port span): common %d  '
          'golden-only %d  ours-only %d' % (len(both), len(gonly), len(oonly)))
    t = defaultdict(int)
    diffs = []
    for k in both:
        a, b = gc[k]['kind'], oc[k]['kind']
        t[(a, b)] += 1
        if a != b:
            diffs.append(k)
    for k in sorted(t):
        mark = '' if k[0] == k[1] else '   <-- DIVERGENT'
        print('    golden %-22s -> ours %-22s %6d%s' % (k[0], k[1], t[k], mark))

    print()
    print('Q3  DIVERGENT CELLS (%d)' % len(diffs))
    fam = defaultdict(list)
    for k in diffs:
        fam[(gc[k]['kind'], oc[k]['kind'])].append(k)
    for f in sorted(fam):
        print('  family golden %s -> ours %s : %d' % (f[0], f[1], len(fam[f])))
        for k in sorted(fam[f])[:80]:
            print('    %-12s %-58s port %-22s @%-16s' % (k[0], k[1], k[2], k[3]))
            print('        G: %s' % desc(gc[k]))
            print('        O: %s' % desc(oc[k]))

    print()
    print('Q4  golden constant high conns: shape tally')
    t = defaultdict(int)
    for r in gc.values():
        if r['kind'] == 'constant':
            t[(r['key'][0], r.get('parent', ('<none>', ''))[0],
               bool(r.get('ts')))] += 1
    for k in sorted(t):
        print('    %-14s parent=%-16s typespec=%-5s %d' % (k[0], k[1], k[2], t[k]))
    print()
    print('    ours constant high conns:')
    t = defaultdict(int)
    for r in oc.values():
        if r['kind'] == 'constant':
            t[(r['key'][0], r.get('parent', ('<none>', ''))[0],
               bool(r.get('ts')))] += 1
    for k in sorted(t):
        print('    %-14s parent=%-16s typespec=%-5s %d' % (k[0], k[1], k[2], t[k]))

    print()
    print('Q5  GOLDEN-ONLY keys (%d), first 40' % len(gonly))
    for k in gonly[:40]:
        print('    %-12s %-58s port %-22s @%s -> %s' % (k[0], k[1], k[2], k[3], desc(gc[k])))
    print('    OURS-ONLY keys (%d), first 40' % len(oonly))
    for k in oonly[:40]:
        print('    %-12s %-58s port %-22s @%s -> %s' % (k[0], k[1], k[2], k[3], desc(oc[k])))


main()
