#!/usr/bin/env python3
"""r10earl45 grid — every OPERATION in a probe file, BOTH SIDES, keyed on
(section, scope path, span, ordinal), printing the fields expr::Compare and
operation::Compare actually read plus the pattern NESTING DEPTH and the
OPERAND INDEX of the op inside its parent operation.

LHS is ALWAYS golden (Surelog).  RHS is ALWAYS ours.

    usage: grid45.py <g.dump> <o.dump> [--all]

Without --all only op75 (assignment pattern) rows print; with --all every
operation prints.  A row is MATCH only when EVERY printed field agrees.

The printed fields are exactly the cmp-visible ones for an `operation`:
    vpiOpType, vpiReordered, vpiFlattened, vpiOpStrong   (operation::Compare)
    vpiDecompile, vpiSize, Typespec presence             (expr::Compare)
    vpiName, vpiDefName                                  (BaseClass::Compare)
plus `idx` and `depth`, which are STRUCTURE, not fields — they are what the
law keys on.  vpiParent is printed for reference and marked INERT: no
generated Compare body in UHDM reads it.
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
           'vpiTaskFunc')
KEEP = ('vpiOpType', 'vpiReordered', 'vpiFlattened', 'vpiOpStrong',
        'vpiDecompile', 'vpiSize', 'vpiName', 'vpiDefName')


def parse(path):
    section = None
    stack = []
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
                ind, name, val = len(m.group(1)), m.group(2), m.group(3)
                close_to(ind)
                if not stack:
                    continue
                owner = stack[-1]
                owner[4] = name
                r = owner[5]
                if r is not None:
                    if name in KEEP:
                        r['f'][name] = val.strip()
                    elif name == 'vpiTypespec':
                        r['ts'] = 'yes'
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
                if pfield in BACKREF:
                    if parent is not None and parent[5] is not None:
                        parent[5].setdefault('par', (kind, span))
                    continue
                rec = None
                if kind == 'operation':
                    depth = 0
                    for fr in stack:
                        if fr[5] is not None and \
                                fr[5]['f'].get('vpiOpType') == '75':
                            depth += 1
                    scope = '/'.join(s[1] for s in scopestack) or '-'
                    base = (section, scope, span)
                    counts[base] += 1
                    idx = None
                    if parent is not None and parent[5] is not None:
                        parent[5]['nkids'] = parent[5].get('nkids', 0) + 1
                        idx = parent[5]['nkids'] - 1
                    rec = {'f': {}, 'ts': None, 'par': None, 'depth': depth,
                           'idx': idx, 'scope': scope, 'span': span,
                           'section': section, 'nkids': 0}
                    ops[base + (counts[base],)] = rec
                stack.append([ind, kind, span, nm, None, rec])
                if kind in SCOPEKINDS:
                    scopestack.append((ind, nm))
    return ops


def desc(r):
    if r is None:
        return '<absent>'
    f = r['f']
    return ('op=%-4s sz=%-6s dec=%-6s reord=%-4s ts=%-4s nm=%-6s par=%s' %
            (f.get('vpiOpType'), f.get('vpiSize'), f.get('vpiDecompile'),
             f.get('vpiReordered'), r['ts'], f.get('vpiName'),
             (r['par'][1] if r['par'] else None)))


def cmpfields(a, b):
    """Compare only what UHDM's Compare bodies read.  vpiParent is INERT."""
    if a is None or b is None:
        return False
    for k in KEEP:
        if a['f'].get(k) != b['f'].get(k):
            return False
    return a['ts'] == b['ts']


def main():
    showall = '--all' in sys.argv
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    g = parse(args[0])
    o = parse(args[1])
    keys = sorted(set(g) | set(o))
    rows = nonmatch = 0
    for k in keys:
        gr, orr = g.get(k), o.get(k)
        if not showall:
            if not ((gr and gr['f'].get('vpiOpType') == '75') or
                    (orr and orr['f'].get('vpiOpType') == '75')):
                continue
        ok = cmpfields(gr, orr)
        rows += 1
        if not ok:
            nonmatch += 1
        print('%-7s %-11s %-30s %-16s d=%s i=%s' %
              ('MATCH' if ok else 'DIFFER', k[0], k[1][:30], k[2],
               (gr or orr)['depth'], (gr or orr)['idx']))
        print('           G  %s' % desc(gr))
        print('           O  %s' % desc(orr))
    print('ROWS %d  NON-MATCH %d   (vpiParent printed but INERT: no UHDM '
          'Compare body reads it)' % (rows, nonmatch))


if __name__ == '__main__':
    main()
