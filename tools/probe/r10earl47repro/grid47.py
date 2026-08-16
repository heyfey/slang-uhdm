#!/usr/bin/env python3
"""r10earl47 GRID reader — for every REFERENCE-position leaf in the arm, print
what each side put there, cell for cell.

    usage: grid47.py <g.dump> <o.dump> [scope-substring, default "gen_x[0]"]

A row is one leaf: the (scope, field, span) key the census uses.  The value is
the leaf's KIND plus, for a constant, the fields uhdm-cmp actually reads
(vpiDecompile / vpiSize / vpiConstType) and — as evidence of the SHARE, which
cmp does NOT read — the printed vpiParent's kind.

LHS is ALWAYS golden (Surelog).  RHS is ALWAYS ours.  Both dumps must already
have uhdm-dump's first line stripped.
"""
import re, sys

NODE = re.compile(r'^(\s*)\\_(\w+):(.*)$')
FIELD = re.compile(r'^(\s*)\|(\w+):(.*)$')
LOC = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')
PAREN = re.compile(r'\(([^()]*)\)')
LEAFFIELDS = ('vpiWidthExpr', 'vpiBaseExpr', 'vpiLeftRange', 'vpiRightRange',
              'vpiIndex', 'vpiOperand', 'vpiRhs', 'vpiHighConn', 'vpiArgument',
              'vpiExpr')


def span_of(rest):
    m = LOC.search(rest)
    return '?' if not m else '%s:%s-%s:%s' % m.groups()


def scan(path, want):
    rows = {}
    stack = []
    pend, pind = '', -1
    view = 0            # each INDENT-0 module_inst is a separate VIEW: the
                        # def (allModules) view and the elab (topModules) view
                        # carry the SAME scope names and must never be merged.
    with open(path, errors='replace') as f:
        for line in f:
            m = NODE.match(line)
            if m:
                ind, kind, rest = len(m.group(1)), m.group(2), m.group(3)
                if ind == 0 and kind == 'module_inst':
                    view += 1
                while stack and stack[-1][0] >= ind:
                    stack.pop()
                field = pend if pind == ind else ''
                if field == 'vpiParent':
                    if stack:
                        stack[-1][2]['parent'] = kind
                    continue
                pm = PAREN.search(rest)
                nm = pm.group(1) if pm else ''
                scope = ''
                for e in reversed(stack):
                    if e[2].get('name'):
                        scope = e[2]['name']
                        break
                rec = {'kind': kind, 'name': nm, 'span': span_of(rest),
                       'field': field, 'scope': scope,
                       'container': stack[-1][1] if stack else ''}
                if (field in LEAFFIELDS and kind in ('constant', 'ref_obj')
                        and want in scope):
                    rows[(view, scope, field, rec['span'])] = rec
                stack.append([ind, kind, rec])
                continue
            m = FIELD.match(line)
            if m:
                ind, pend, pind = len(m.group(1)), m.group(2), len(m.group(1))
                val = m.group(3).strip()
                if val:
                    for e in reversed(stack):
                        if e[0] == ind - 2:
                            e[2][m.group(2)] = val
                            break
    return rows


def fmt(r):
    if r is None:
        return 'ABSENT'
    if r['kind'] != 'constant':
        return '%s(%s)' % (r['kind'], r.get('vpiName', ''))
    val = ''
    for k in ('INT', 'UINT', 'BIN', 'HEX', 'OCT'):
        if k in r:
            val = k + ':' + r[k]
            break
    return 'const %s ct%s sz%s dec=%s par=%s' % (
        val, r.get('vpiConstType', '-'), r.get('vpiSize', '-'),
        r.get('vpiDecompile', '-'), r.get('parent', '-'))


def main():
    want = sys.argv[3] if len(sys.argv) > 3 else 'gen_x[0]'
    g = scan(sys.argv[1], want)
    o = scan(sys.argv[2], want)
    keys = sorted(set(g) | set(o), key=lambda k: (k[0], k[3], k[2]))
    print('%-3s %-30s %-14s %-13s | %-44s | %-44s | %s'
          % ('VW', 'SCOPE', 'FIELD', 'SPAN', 'GOLDEN', 'OURS', 'VERDICT'))
    nbad = 0
    for k in keys:
        gr, orr = g.get(k), o.get(k)
        gs, os_ = fmt(gr), fmt(orr)
        bad = gs != os_
        nbad += bad
        print('%-3d %-30s %-14s %-13s | %-44s | %-44s | %s'
              % (k[0], k[1][-30:], k[2], k[3], gs, os_,
                 'DIFF <<<' if bad else 'same'))
    print('\nrows=%d  differing=%d   (scope filter %r)' % (len(keys), nbad, want))


main()
