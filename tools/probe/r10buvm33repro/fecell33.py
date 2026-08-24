#!/usr/bin/env python3
"""r10buvm33repro/fecell33.py — the FOREACH-HEADER cell reader.  MEASUREMENT ONLY.

For every `foreach_stmt` in a uhdm-dump text, print one row:

    <foreach line:col>  VAR=<kind>'<name>'@<span>  TS=<kind>'<name>'@<span>

reading the object under `|vpiVariables:` and, inside it, the
`|vpiTypespec:` -> `|vpiActual:` leaf.  Indentation is the tree, so the
sub-object is everything indented deeper than the `\\_foreach_stmt` line until
the indentation returns.  The dump prints a REVISIT of an already-emitted
object as a one-line stub, which is why the typespec is read from the FIRST
`vpiActual` at the variable's own depth+2 and never from a stub.

  usage: fecell33.py <dump.txt> [<dump.txt> ...]
"""
import re, sys

OBJ = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?(.*)$')
LOC = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')
FLD = re.compile(r'^(\s*)\|(\w+):')

def parse(path):
    rows = []
    lines = open(path, errors='replace').read().split('\n')
    n = len(lines)
    for i, ln in enumerate(lines):
        m = OBJ.match(ln)
        if not m or m.group(2) != 'foreach_stmt':
            continue
        ind = len(m.group(1))
        loc = LOC.search(ln)
        fkey = '%s:%s' % (loc.group(1), loc.group(2)) if loc else '?'
        # walk forward inside this foreach_stmt
        var = None; ts = None; invars = False; vind = None
        j = i + 1
        while j < n:
            l2 = lines[j]
            if l2.strip() == '':
                j += 1; continue
            f = FLD.match(l2); o = OBJ.match(l2)
            cur = len(f.group(1)) if f else (len(o.group(1)) if o else None)
            if cur is None:
                j += 1; continue
            if cur <= ind and not (f and cur == ind + 2) and not (o and cur == ind + 2):
                break
            if f and cur == ind + 2:
                invars = (f.group(2) == 'vpiVariables')
                if f.group(2) in ('vpiLoopVars', 'vpiStmt'):
                    if var is not None:
                        break
                    invars = False
            elif o and cur == ind + 2 and invars and var is None:
                lc = LOC.search(l2)
                var = (o.group(2), o.group(3) or '',
                       '%s:%s-%s:%s' % lc.groups() if lc else '-')
                vind = cur
            elif o and var is not None and ts is None and vind is not None \
                    and cur > vind and o.group(2).endswith('typespec') \
                    and o.group(2) != 'ref_typespec':
                lc = LOC.search(l2)
                ts = (o.group(2), o.group(3) or '',
                      '%s:%s-%s:%s' % lc.groups() if lc else '-')
            j += 1
        rows.append((fkey, var, ts))
    return rows

for p in sys.argv[1:]:
    print('== %s' % p)
    for fkey, var, ts in parse(p):
        vs = "%s'%s'@%s" % var if var else '<none>'
        tss = "%s'%s'@%s" % ts if ts else '<none>'
        print('  fe@%-10s VAR=%-58s TS=%s' % (fkey, vs, tss))
