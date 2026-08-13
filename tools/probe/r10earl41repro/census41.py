#!/usr/bin/env python3
"""r10earl41 — THE QUALIFIED-BASE SELECT CENSUS, span-keyed, BOTH SIDES,
VIEW-SEPARATED (def = uhdmallModules, elab = uhdmtopModules).

r10earl40 cleared the DEF-view STRUCTURE defect (a pasted-text `ref_obj`).  Its
recorded residue R1 is the ELABORATED twin: we build the right structure but
name the base with its BARE tail where golden names it with the PACKAGE
QUALIFIER.  This census reads the STORED `|vpiName:` field (not the header's
computed display string, which is a different mechanism) so a name defect and a
parent-chain defect cannot be confused.

Three questions, all answered from the two pristine dumps BEFORE any code:

  Q1  How many select-family objects carry a QUALIFIED stored vpiName, per view,
      on each side?  (the population)
  Q2  At the spans where golden's name is qualified, what do WE emit — same kind
      with a bare name (the R1 defect), a different kind, or nothing?
  Q3  R5 CAUTION: at spans where WE emit a select in the elab view, does golden
      CONSTANT-FOLD instead?  A fold is not a naming defect and must not be
      counted as a mover.

usage: census41.py <golden.dump> <ours.dump>     (both already `sed 1d`-ed)
"""
import re
import sys
from collections import Counter

HDR = re.compile(r'^( *)\\_([a-z_]+): *(.*?)'
                 r'(?:, )?line:(\d+):(\d+), endln:(\d+):(\d+)\s*$')
FLD = re.compile(r'^( *)\|([A-Za-z]+):(.*)$')
SELKINDS = ('var_select', 'part_select', 'bit_select', 'indexed_part_select')


def scan(path):
    """Return list of objects: dict(kind, span, name, full, view, defname)."""
    objs = []
    # view boundaries are found in a first pass over the section labels
    view = 'pre'
    stack = []          # (indent, obj)
    for ln in open(path, errors='replace'):
        ln = ln.rstrip('\n')
        if ln.startswith('|uhdmallModules:'):
            view = 'def'
            continue
        if ln.startswith('|uhdmtopModules:'):
            view = 'elab'
            continue
        m = HDR.match(ln)
        if m:
            ind, kind, mid, l1, c1, l2, c2 = m.groups()
            ind = len(ind)
            while stack and stack[-1][0] >= ind:
                stack.pop()
            o = dict(kind=kind, span='%s:%s-%s:%s' % (l1, c1, l2, c2),
                     name=None, full=None, defname=None, view=view,
                     display=mid.strip(), nf=0)
            # A header printed under a |vpiParent:/|vpiActual: label is a
            # BACK-REFERENCE, not a new object.  uhdm-dump prints NO field
            # lines under a back-reference, so `nf == 0` separates the two
            # populations exactly and every count below filters on it.
            objs.append(o)
            stack.append((ind, o))
            continue
        m = FLD.match(ln)
        if m:
            ind, fld, val = m.groups()
            ind = len(ind)
            while stack and stack[-1][0] >= ind:
                stack.pop()
            if stack and isinstance(stack[-1][1], dict):
                o = stack[-1][1]
                o['nf'] += 1
                if fld == 'vpiName':
                    o['name'] = val
                elif fld == 'vpiFullName':
                    o['full'] = val
                elif fld == 'vpiDefName':
                    o['defname'] = val
    return [x for x in objs if x['nf']]


def keyed(objs, kinds):
    d = {}
    for o in objs:
        if o['kind'] in kinds and o['name'] is not None:
            d.setdefault((o['view'], o['kind'], o['span'], o['name']), 0)
            d[(o['view'], o['kind'], o['span'], o['name'])] += 1
    return d


def main():
    g = scan(sys.argv[1])
    o = scan(sys.argv[2])
    print('objects parsed: golden=%d ours=%d' % (len(g), len(o)))

    # ---- Q1  qualified stored vpiName per view/kind -------------------------
    print('\n=== Q1  select-family objects with a QUALIFIED stored vpiName '
          '(contains `::`)')
    print('%-6s %-22s %8s %8s %8s' % ('view', 'kind', 'golden', 'ours', 'delta'))
    gc = Counter((x['view'], x['kind']) for x in g
                 if x['kind'] in SELKINDS and x['name'] and '::' in x['name'])
    oc = Counter((x['view'], x['kind']) for x in o
                 if x['kind'] in SELKINDS and x['name'] and '::' in x['name'])
    for k in sorted(set(gc) | set(oc)):
        print('%-6s %-22s %8d %8d %+8d' % (k[0], k[1], gc[k], oc[k],
                                           oc[k] - gc[k]))
    print('\n--- ALL select-family objects (any name), for context')
    gA = Counter((x['view'], x['kind']) for x in g if x['kind'] in SELKINDS)
    oA = Counter((x['view'], x['kind']) for x in o if x['kind'] in SELKINDS)
    for k in sorted(set(gA) | set(oA)):
        print('%-6s %-22s %8d %8d %+8d' % (k[0], k[1], gA[k], oA[k],
                                           oA[k] - gA[k]))

    # ---- Q2  span join on golden's qualified names --------------------------
    print('\n=== Q2  GOLDEN qualified-name select spans, and what WE put there')
    ospan = {}
    for x in o:
        if x['kind'] in SELKINDS and x['name'] is not None:
            ospan.setdefault((x['view'], x['span']), Counter())[
                (x['kind'], x['name'])] += 1
    rows = Counter()
    detail = {}
    for x in g:
        if not (x['kind'] in SELKINDS and x['name'] and '::' in x['name']):
            continue
        key = (x['view'], x['span'])
        mine = ospan.get(key, Counter())
        same = [n for (k2, n) in mine if k2 == x['kind']]
        if not mine:
            verdict = 'WE_HAVE_NOTHING'
        elif x['name'] in same:
            verdict = 'MATCH'
        elif same and x['name'].rsplit('::', 1)[-1] in same:
            verdict = 'BARE_TAIL(R1)'
        elif same:
            verdict = 'OTHER_NAME'
        else:
            verdict = 'OTHER_KIND'
        rows[(x['view'], x['kind'], verdict)] += 1
        detail.setdefault((x['view'], verdict), []).append(
            (x['span'], x['kind'], x['name'],
             sorted(set(mine.elements())) if mine else []))
    for k in sorted(rows):
        print('%-6s %-22s %-16s %6d' % (k[0], k[1], k[2], rows[k]))
    for k in sorted(detail):
        if k[1] == 'MATCH':
            continue
        print('\n--- %s / %s  (distinct spans, first 20)' % k)
        seen = set()
        for sp, kd, nm, mine in sorted(detail[k]):
            if (sp, kd, nm) in seen:
                continue
            seen.add((sp, kd, nm))
            if len(seen) > 20:
                print('    ... more')
                break
            print('    %-16s G:%-18s %s' % (sp, kd, nm))
            for mk, mn in mine:
                print('    %-16s O:%-18s %s' % ('', mk, mn))

    # ---- Q3  R5: golden folds where we select (elab only) -------------------
    print('\n=== Q3  R5 CAUTION — spans where OURS has a select and golden has'
          ' NO select object (elab view)')
    gspan = {}
    for x in g:
        gspan.setdefault((x['view'], x['span']), Counter())[x['kind']] += 1
    miss = Counter()
    ex = []
    for x in o:
        if x['view'] != 'elab' or x['kind'] not in SELKINDS:
            continue
        gk = gspan.get((x['view'], x['span']), Counter())
        if not any(k in SELKINDS for k in gk):
            miss[(x['kind'], ','.join(sorted(gk)) or '<none>')] += 1
            if len(ex) < 20:
                ex.append((x['span'], x['kind'], x['name'],
                           ','.join(sorted(gk)) or '<none>'))
    for k in miss.most_common(20):
        print('   ours=%-20s golden-at-span=%-28s %d' % (k[0][0], k[0][1], k[1]))
    for e in ex:
        print('   ex %-16s O:%-16s %-40s G:%s' % e)


if __name__ == '__main__':
    main()
