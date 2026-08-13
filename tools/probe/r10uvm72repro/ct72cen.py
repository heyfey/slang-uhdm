#!/usr/bin/env python3
"""r10uvm72repro/ct72cen.py — census of CALL SITES and their callee linkage,
ONE SIDE PER RUN (LHS is always golden; this script never opens two files, so it
cannot silently mix the two databases).

uhdm-dump prints an object MANY times: once FULL (its own fields at indent+2)
and any number of times as a BACK-REFERENCE header under some other object's
field (no fields of its own).  A census that counts header lines counts backrefs
and lies.  This one:

  * keys every call object on (kind, vpiName, line:col-endln) -- the SPAN, which
    is stable across prints and across the two databases;
  * counts a print FULL only when at least one field line sits at indent+2;
  * MERGES an object's several full prints and REPORTS disagreement
    (CALL_DISAGREE) instead of silently taking the last one;
  * records the enclosing print chain, so the BOUND and UNBOUND populations can
    be split by CALLER CONTEXT -- the axis this pass decodes.

usage:
  ct72cen.py <dump> [--callee NAME] [--kinds k1,k2] [--linkfield vpiFunction]
             [--tsv]
"""
import re
import sys
import argparse
from collections import Counter

OBJ = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?(.*)$')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')
SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')
FILE = re.compile(r'file:([^,]+)')

CTX_KINDS = ('function', 'task', 'class_defn', 'package', 'module_inst',
             'gen_scope', 'initial', 'always', 'class_typespec')


def ctx(anc):
    for kind, name, span in reversed(anc):
        if kind in CTX_KINDS:
            return '%s %s' % (kind, name)
    return '<none>'


def census(path, kinds, linkfield):
    """key -> {'prints': [frozenset(fields), ...], 'anc': tuple, 'backrefs': n}"""
    recs = {}
    stack = []
    openc = []

    def commit(oc):
        ind, key, flds, anc = oc
        r = recs.setdefault(key, {'prints': [], 'anc': anc, 'backrefs': 0})
        if flds:
            r['prints'].append(frozenset(flds))
            r['anc'] = anc
        else:
            r['backrefs'] += 1

    for ln in open(path, errors='replace'):
        ln = ln.rstrip('\n')
        m = OBJ.match(ln)
        if m:
            ind = len(m.group(1))
            kind, name, rest = m.group(2), m.group(3) or '', m.group(4)
            sp = SPAN.search(rest)
            span = ('%s:%s-%s:%s' % sp.groups()) if sp else '?'
            fm = FILE.search(rest)
            while stack and stack[-1][0] >= ind:
                stack.pop()
            # uhdm-dump prints `file:` only where it CHANGES; a span without its
            # file is not a key -- 114:10-114:67 exists in many UVM files -- so
            # the file is inherited down the print chain.
            fl = fm.group(1) if fm else (stack[-1][4] if stack else '')
            for oc in [o for o in openc if o[0] >= ind]:
                commit(oc)
            openc = [o for o in openc if o[0] < ind]
            stack.append((ind, kind, name, span, fl))
            if kind in kinds:
                anc = tuple((s[1], s[2], s[3]) for s in stack[:-1])
                openc.append([ind, (kind, name, fl.split('/')[-1] + ' ' + span),
                              set(), anc])
            continue
        m = FLD.match(ln)
        if m:
            ind, fld = len(m.group(1)), m.group(2)
            for oc in openc:
                if ind == oc[0] + 2:
                    oc[2].add(fld)
    for oc in openc:
        commit(oc)
    return recs


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('dump')
    ap.add_argument('--callee', default=None)
    ap.add_argument('--kinds',
                    default='func_call,method_func_call,task_call,method_task_call')
    ap.add_argument('--linkfield', default='vpiFunction')
    ap.add_argument('--tsv', action='store_true')
    a = ap.parse_args()
    kinds = set(a.kinds.split(','))
    recs = census(a.dump, kinds, a.linkfield)
    sel = {k: v for k, v in recs.items() if a.callee is None or k[1] == a.callee}

    def bound(v):
        return bool(v['prints']) and all(a.linkfield in p for p in v['prints'])

    def unbound(v):
        return bool(v['prints']) and all(a.linkfield not in p for p in v['prints'])

    B = {k: v for k, v in sel.items() if bound(v)}
    U = {k: v for k, v in sel.items() if unbound(v)}
    D = {k: v for k, v in sel.items() if v['prints'] and not bound(v) and not unbound(v)}
    N = {k: v for k, v in sel.items() if not v['prints']}

    if a.tsv:
        for k in sorted(sel):
            v = sel[k]
            st = 'BOUND' if bound(v) else ('UNBOUND' if unbound(v)
                                           else ('DISAGREE' if v['prints'] else 'NOFULL'))
            print('%s\t%s\t%s\t%s\t%d\t%d\t%s' %
                  (k[0], k[1], k[2], st, len(v['prints']), v['backrefs'], ctx(v['anc'])))
        return
    print('dump: %s' % a.dump)
    print('kinds=%s linkfield=%s callee=%s' % (a.kinds, a.linkfield, a.callee))
    print('call objects (merged by span): %d' % len(sel))
    print('  BOUND    : %d' % len(B))
    print('  UNBOUND  : %d' % len(U))
    print('  CALL_DISAGREE (full prints disagree): %d' % len(D))
    print('  NO_FULL_PRINT (backref only)        : %d' % len(N))
    for k in list(D)[:20]:
        print('    DISAGREE %s' % (k,))
    for lbl, pop in (('BOUND', B), ('UNBOUND', U)):
        c = Counter(ctx(v['anc']) for v in pop.values())
        print('  --- %s by nearest named ancestor (top 15 of %d) ---' % (lbl, len(c)))
        for kk, n in c.most_common(15):
            print('      %5d  %s' % (n, kk))


main()
