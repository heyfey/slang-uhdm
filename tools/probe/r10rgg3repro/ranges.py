#!/usr/bin/env python3
"""r10rgg3/ranges.py — print (scope.member -> left,right) for every
parameter-dependent declaration range in a uhdm-dump, plus each interface_inst's
own parameter values and param_assign Rhs values.

The dump prints a declaration's typespec ONCE, in the weakly-referenced tail,
with its owning variable as vpiParent — so the parent's vpiFullName is the key.
A member that prints NO vpiDecompile is reported as `-` and never silently
dropped.
"""
import re, sys

def load(f):
    lines = open(f, errors='replace').read().split('\n')
    rng = {}
    for i, l in enumerate(lines):
        m0 = re.match(r'\\_(\w*typespec): , line:(\d+):(\d+)', l)
        if not m0:
            continue
        m = re.search(r'\((\S+?)\)', lines[i + 2]) if i + 2 < len(lines) else None
        if not m:
            continue
        d = []
        for j in range(i + 1, min(i + 40, len(lines))):
            if re.match(r'\\_', lines[j]):
                break
            mm = re.match(r'\s*\|vpiDecompile:(\S*)', lines[j])
            if mm:
                d.append(mm.group(1))
        rng.setdefault(m.group(1), []).append((m0.group(1), tuple(d) or ('-',)))
    return rng

def params(f):
    """(scope.param -> inlined value) for parameter objects, and param_assign Rhs."""
    lines = open(f, errors='replace').read().split('\n')
    out = {}
    for i, l in enumerate(lines):
        m = re.match(r'\s*\\_parameter: \((\S+?)\),', l)
        if not m:
            continue
        v = None
        for j in range(i + 1, min(i + 12, len(lines))):
            mm = re.match(r'\s*\|(UINT|INT|STRING|SCALAR):(\S*)', lines[j])
            if mm:
                v = mm.group(1) + ':' + mm.group(2)
                break
        out.setdefault(m.group(1), set()).add(v)
    return out

if __name__ == '__main__':
    f = sys.argv[1]
    pat = sys.argv[2] if len(sys.argv) > 2 else r'\.(a|b|v|wn|lpm)$'
    rng = load(f)
    for k in sorted(rng):
        if re.search(pat, k):
            for kind, d in rng[k]:
                print('RANGE %-46s %-24s %s' % (k, kind, ','.join(d)))
    if len(sys.argv) > 3 and sys.argv[3] == 'params':
        for k, v in sorted(params(f).items()):
            print('PARAM %-46s %s' % (k, sorted(x for x in v if x)))
