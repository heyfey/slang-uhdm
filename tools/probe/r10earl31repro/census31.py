#!/usr/bin/env python3
"""r10earl31 — GOLDEN'S TYPESPEC-ATTACHMENT POLICY FOR FOLDED CONSTANTS.

    usage: census31.py <golden.dump> <ours.dump> [--pairs] [--cell <POSITION>]

LHS is ALWAYS golden.  Every constant in the database is classified by its
POSITION (the first non-operation ancestor and the field that carries it, i.e.
where the fold happened) and by its enclosing STATEMENT KIND, and then
cross-tabbed by "does it carry a vpiTypespec".

Why a cross-tab and not a count: a count of "constants with a typespec" cannot
price an attachment rule, because most typespec-carrying constants are parameter
values.  The joint cell (POSITION, has-ts) is the policy.

Why the census must run BEFORE coding (the brief's instruction, and the last two
passes' failure mode): a typespec-attachment law can reach EVERY folded constant,
so the mover prediction has to come from the dumps, not from a hand list.
"""
import sys
from collections import Counter, defaultdict

import tsread

PROC = ('always', 'initial', 'final', 'begin', 'named_begin', 'if_stmt',
        'case_stmt', 'for_stmt', 'while_stmt', 'assignment', 'event_control',
        'case_item', 'do_while', 'foreach_stmt', 'repeat', 'forever')
TF = ('task', 'function', 'task_call', 'func_call', 'method_func_call')


def position(c):
    """(POSITION, depth-of-operations-above-the-constant)"""
    ops = 0
    p, f = c.parent, c.field
    while p is not None and p.type == 'operation':
        ops += 1
        f = p.field
        p, = (p.parent,)
    if p is None or p.type == 'DESIGN':
        return 'ROOT', ops
    return '%s/%s' % (p.type, f), ops


def stmtkind(c):
    p = c.parent
    while p is not None and p.type != 'DESIGN':
        if p.type == 'cont_assign':
            return 'cont_assign'
        if p.type == 'param_assign':
            return 'param_assign'
        if p.type in TF:
            return 'subroutine'
        if p.type in PROC:
            return 'process'
        if p.type in ('port', 'ref_module'):
            return 'port_conn'
        if p.type in ('typespec', 'logic_typespec', 'array_typespec',
                      'packed_array_typespec', 'struct_typespec',
                      'enum_typespec', 'int_typespec', 'bit_typespec',
                      'range'):
            return 'typespec'
        p = p.parent
    return 'other'


def load(path):
    rows = {}
    dup = 0
    for c in tsread.parse(path):
        if c.stub:
            continue
        pos, ops = position(c)
        k = tsread.key(c)
        r = (pos, ops, stmtkind(c), tsread.ts_of(c),
             c.fields.get('VALUE', ''), c.fields.get('vpiSize', ''),
             c.fields.get('vpiConstType', ''), c.span)
        if k in rows:
            dup += 1
            k = k + (dup,)
        rows[k] = r
    return rows


def main():
    g, o = sys.argv[1], sys.argv[2]
    pairs = '--pairs' in sys.argv
    cell = None
    if '--cell' in sys.argv:
        cell = sys.argv[sys.argv.index('--cell') + 1]
    G, O = load(g), load(o)
    print('constants: golden=%d ours=%d' % (len(G), len(O)))

    # ---- the POLICY table: POSITION x has-typespec, both sides
    tab = defaultdict(lambda: [0, 0, 0, 0])   # g_ts, g_bare, o_ts, o_bare
    for src, rows in (('g', G), ('o', O)):
        for k, r in rows.items():
            t = tab[r[0]]
            has = 1 if r[3] else 0
            t[0 if src == 'g' else 2] += has
            t[1 if src == 'g' else 3] += 1 - has
    print('%-46s %8s %8s %8s %8s' % ('POSITION', 'g:TS', 'g:bare', 'o:TS', 'o:bare'))
    for pos in sorted(tab, key=lambda p: -(tab[p][0] + tab[p][1])):
        t = tab[pos]
        print('%-46s %8d %8d %8d %8d' % (pos, t[0], t[1], t[2], t[3]))

    # ---- the JOIN: same constant, both sides, typespec present or not
    both = set(G) & set(O)
    j = Counter()
    examples = defaultdict(list)
    for k in both:
        rg, ro = G[k], O[k]
        v = ('TS_BOTH' if rg[3] and ro[3] else
             'TS_GOLDEN_ONLY' if rg[3] else
             'TS_OURS_ONLY' if ro[3] else 'BARE_BOTH')
        same = (rg[3] == ro[3])
        j[(rg[0], v, 'same' if same else 'DIFFER')] += 1
        if v != 'BARE_BOTH' and len(examples[(rg[0], v)]) < 6:
            examples[(rg[0], v)].append((k, rg, ro))
    print('\njoined constants (same named-ancestor + start span + decompile): %d'
          '  golden-only=%d ours-only=%d'
          % (len(both), len(set(G) - set(O)), len(set(O) - set(G))))
    print('%-46s %-16s %-8s %6s' % ('POSITION', 'verdict', 'ts-equal', 'n'))
    for k in sorted(j, key=lambda x: -j[x]):
        if k[1] == 'BARE_BOTH':
            continue
        print('%-46s %-16s %-8s %6d' % (k[0], k[1], k[2], j[k]))
    print('BARE_BOTH total = %d' % sum(v for k, v in j.items() if k[1] == 'BARE_BOTH'))

    if pairs:
        for (pos, v), ex in sorted(examples.items()):
            if cell and pos != cell:
                continue
            print('\n== %s  %s' % (pos, v))
            for k, rg, ro in ex:
                print('   key=%s' % (k,))
                print('     G ops=%s stmt=%s val=%s sz=%s ct=%s span=%s\n       ts=%s'
                      % (rg[1], rg[2], rg[4], rg[5], rg[6], rg[7], rg[3] or '<bare>'))
                print('     O ops=%s stmt=%s val=%s sz=%s ct=%s span=%s\n       ts=%s'
                      % (ro[1], ro[2], ro[4], ro[5], ro[6], ro[7], ro[3] or '<bare>'))


if __name__ == '__main__':
    main()
