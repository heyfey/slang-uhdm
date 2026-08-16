#!/usr/bin/env python3
"""r10earl47 census — the GEN-SCOPE LOCALPARAM FOLD SUBSTITUTION, both sides.

Golden's signature for a substituted gen-localparam fold at a USE site is a
`constant` whose printed `vpiParent` is a `param_assign` AT A DIFFERENT SPAN
(the declaration's) while the constant itself carries the USE site's span.
This script tallies every such cell on either side, keyed on

    (nearest enclosing named scope, field label, span)

so the two dumps join without a file name (uhdm-dump prints none).

usage:  census47.py <g.dump> <o.dump> [outprefix]
"""
import re, sys, collections

NODE = re.compile(r'^(\s*)\\_(\w+):(.*)$')
FIELD = re.compile(r'^(\s*)\|(\w+):(.*)$')
LOC = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')
PAREN = re.compile(r'\(([^()]*)\)')
KEEP = {'constant', 'ref_obj', 'operation', 'bit_select', 'part_select',
        'indexed_part_select', 'hier_path', 'ref_var', 'var_select',
        'sys_func_call', 'func_call', 'parameter'}


def span_of(rest):
    m = LOC.search(rest)
    return '?' if not m else '%s:%s-%s:%s' % m.groups()


def scan(path, collect):
    """collect(rec) is called with
       (scope, field, span, kind, pkind, pspan, decompile, name, value)."""
    stack = []          # [indent, kind, name, span, field, rec-list, scope]
    pend_field, pend_ind = '', -1
    with open(path, 'r', errors='replace') as f:
        for line in f:
            m = NODE.match(line)
            if m:
                ind = len(m.group(1))
                kind, rest = m.group(2), m.group(3)
                while stack and stack[0 if False else -1][0] >= ind:
                    e = stack.pop()
                    if e[5] is not None:
                        collect(e[5])
                field = pend_field if pend_ind == ind else ''
                if field == 'vpiParent':
                    if stack and stack[-1][5] is not None:
                        stack[-1][5][4] = kind
                        stack[-1][5][5] = span_of(rest)
                    continue
                pm = PAREN.search(rest)
                nm = pm.group(1) if pm else ''
                scope = ''
                for e in reversed(stack):
                    if e[2]:
                        scope = e[2]
                        break
                rec = None
                if kind in KEEP:
                    rec = [scope, field, span_of(rest), kind, '', '', '',
                           nm, '', stack[-1][1] if stack else '']
                stack.append([ind, kind, nm or '', span_of(rest), field, rec,
                              scope])
                continue
            m = FIELD.match(line)
            if m:
                ind = len(m.group(1))
                pend_field, pend_ind = m.group(2), ind
                rest = m.group(3).strip()
                if rest:
                    for e in reversed(stack):
                        if e[0] == ind - 2:
                            if e[5] is not None:
                                if m.group(2) == 'vpiDecompile':
                                    e[5][6] = rest
                                elif m.group(2) in ('INT', 'UINT', 'BIN',
                                                    'HEX', 'OCT', 'STRING'):
                                    e[5][8] = m.group(2) + ':' + rest
                            break
    while stack:
        e = stack.pop()
        if e[5] is not None:
            collect(e[5])


def key_of(r):
    return (r[0], r[1], r[2])


def substituted(r):
    """A fold constant SUBSTITUTED at a USE site: it claims a param_assign as
    vpiParent while structurally hanging somewhere else entirely (the
    declaration's own Rhs constant has container == param_assign and is NOT
    a substitution)."""
    return (r[3] == 'constant' and r[4] == 'param_assign'
            and r[9] != 'param_assign')


def main():
    g, o = sys.argv[1], sys.argv[2]
    pref = sys.argv[3] if len(sys.argv) > 3 else 'census47'

    gsub, gcells = {}, [0]
    def gcol(r):
        if substituted(r):
            gcells[0] += 1
            gsub.setdefault(key_of(r), r)
    scan(g, gcol)
    print('GOLDEN substituted-fold constants: %d printed cells, %d keys'
          % (gcells[0], len(gsub)))
    by_fc = collections.Counter()
    for k, r in gsub.items():
        by_fc[(r[9] + " . " + r[1],)] += 1
    print('\n-- GOLDEN substituted, by USE POSITION (field) --')
    for (fld,), n in by_fc.most_common():
        print('  %-24s %6d' % (fld, n))

    omap, osub = {}, {}
    def ocol(r):
        k = key_of(r)
        if k in gsub:
            omap.setdefault(k, r)
        if substituted(r):
            osub.setdefault(k, r)
    scan(o, ocol)
    print('\nOURS substituted-fold constants: %d keys' % len(osub))

    join = collections.Counter()
    rows = []
    for k, r in gsub.items():
        orr = omap.get(k)
        if orr is None:
            join[('ABSENT', r[9] + ' . ' + r[1])] += 1
            rows.append((k, r, None))
        elif substituted(orr):
            join[('ours-substituted', r[9] + ' . ' + r[1])] += 1
            if orr[6] != r[6] or orr[8] != r[8]:
                rows.append((k, r, orr))
        else:
            join[('ours-' + orr[3], r[9] + ' . ' + r[1])] += 1
            rows.append((k, r, orr))
    print('\n-- JOIN: golden substituted vs OURS (by field) --')
    for (st, fld), n in join.most_common():
        print('  %-22s %-24s %6d' % (st, fld, n))

    over = collections.Counter()
    for k, r in osub.items():
        if k not in gsub:
            over[r[9] + ' . ' + r[1]] += 1
    print('\n-- OVER-FIRE: ours substituted at a key golden does not --')
    for fld, n in over.most_common():
        print('  %-24s %6d' % (fld, n))

    with open(pref + '_cells.txt', 'w') as fh:
        for k, r, orr in sorted(rows):
            fh.write('%s | %s | %s | g=%s dec=%s val=%s | o=%s %s dec=%s\n'
                     % (k[0], k[1], k[2], r[3], r[6], r[8],
                        orr[3] if orr else 'ABSENT',
                        orr[7] if orr else '', orr[6] if orr else ''))
    print('\ndiffering/absent cells -> %s_cells.txt (%d rows)' % (pref, len(rows)))


main()
