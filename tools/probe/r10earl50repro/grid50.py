#!/usr/bin/env python3
"""r10earl50 grid reader.

For every ELABORATED `param_assign` in a uhdm-dump, print

    <instance>.<param>  <BARE|LOCATED|NONE>  <typespec kind>@<span>

where BARE means the Rhs constant's `vpiTypespec -> ref_typespec -> vpiActual`
is a SPAN-LESS typespec (Surelog's setRange rewrite -- a fresh loc-less
logic_typespec whose only range is the folded [left:right] as bare UINT
constants) and LOCATED means it is the parameter's own span-bearing
declaration typespec.

The elaborated view is everything from the LAST `|uhdmtopModules:` marker to
the `\\_weaklyReferenced:` tail; pass --all to read the whole file instead.

  usage: grid50.py <dump> [--all]
"""
import sys
import re

OBJ = re.compile(r'^( *)\\_([a-zA-Z_]+): ?(.*)$')
PROP = re.compile(r'^( *)\|([a-zA-Z_]+):(.*)$')


def span_of(rest):
    m = re.search(r'line:(\d+):(\d+), endln:(\d+):(\d+)', rest)
    return 'NOSPAN' if not m else '%s:%s-%s:%s' % m.groups()


def paren_name(rest):
    m = re.search(r'\(([^)]*)\)', rest)
    return m.group(1) if m else ''


def bounds(path, allv):
    lines = open(path, 'rb').read().decode('utf-8', 'replace').split('\n')
    lo, hi = 1, len(lines)
    if not allv:
        for i, l in enumerate(lines, 1):
            if l == '|uhdmtopModules:':
                lo = i
            if l.startswith('\\_weaklyReferenced'):
                hi = i - 1
                break
    return lines, lo, hi


def main():
    path = sys.argv[1]
    allv = '--all' in sys.argv
    lines, lo, hi = bounds(path, allv)
    stack = {}
    lastprop = {}
    rows = []
    # state for the current param_assign
    for n in range(lo, hi + 1):
        line = lines[n - 1]
        m = PROP.match(line)
        if m:
            lastprop[len(m.group(1))] = m.group(2)
            continue
        m = OBJ.match(line)
        if not m:
            continue
        ind, kind, rest = len(m.group(1)), m.group(2), m.group(3)
        prop = lastprop.get(ind, '')
        stack[ind] = [kind, rest, prop]
        for k in [k for k in list(stack) if k > ind]:
            del stack[k]
        for k in [k for k in list(lastprop) if k > ind]:
            del lastprop[k]
        # vpiActual of a ref_typespec that is the vpiTypespec of a constant
        # that is the vpiRhs of a param_assign
        if prop != 'vpiActual':
            continue
        rt = stack.get(ind - 2)
        if not rt or rt[0] != 'ref_typespec' or rt[2] != 'vpiTypespec':
            continue
        cst = stack.get(ind - 4)
        if not cst or cst[0] != 'constant' or cst[2] != 'vpiRhs':
            continue
        pa = stack.get(ind - 6)
        if not pa or pa[0] != 'param_assign':
            continue
        sp = span_of(rest)
        rows.append((n, sp == 'NOSPAN', kind, sp, span_of(pa[1])))
    # attach the LHS parameter name: it is the `\_parameter:` under |vpiLhs:
    # of the same param_assign, which follows the Rhs in the dump.
    out = []
    for (n, bare, kind, sp, paspan) in rows:
        nm = '?'
        for j in range(n, min(n + 40, hi)):
            l = lines[j]
            mm = OBJ.match(l)
            if mm and mm.group(2) == 'parameter':
                nm = paren_name(mm.group(3))
                break
        out.append('%-46s %-8s %s@%s   pa=%s' %
                   (nm, 'BARE' if bare else 'LOCATED', kind, sp, paspan))
    for r in sorted(set(out)):
        print(r)


main()
