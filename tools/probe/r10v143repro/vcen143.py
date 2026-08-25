#!/usr/bin/env python3
"""r10v143 — DEEP cell census for § hpIdxClassBodyNeverLateBinds143.

MEASUREMENT ONLY.  The official uhdm-cmp is the judge.  LHS IS ALWAYS GOLDEN.

Unlike the pass's own `score143.py` -- which keys on a ref_obj whose IMMEDIATE
printed parent is a `bit_select` under `vpiIndex` -- this walks the WHOLE index
subtree of every `hier_path` ELEMENT, so it sees the references the emitter's
helper also walks: operands of an operation, arguments and receivers of a call,
the indices of a NESTED select, and the ranges of a part select.  Those cells
are invisible to a depth-1 key.

A cell is (ref fullname, ref line:col, DEPTH) -> bound?/actual kind.
DEPTH 1 = the index expression itself, >1 = nested inside it.

usage: vcen143.py <dump>            # print cells
       vcen143.py <gold> <ours>     # join, classify
"""
import re, sys, collections

NODE = re.compile(r'^( *)\\_([A-Za-z_0-9]+): ?(.*)$')
FLD  = re.compile(r'^( *)\|([A-Za-z_0-9]+):(.*)$')
LOC  = re.compile(r'line:(\d+):(\d+)')

def parse(path):
    """Return list of (indent, 'N'|'F', name, rest) for each meaningful line."""
    out = []
    for l in open(path, errors='replace').read().split('\n'):
        m = NODE.match(l)
        if m:
            out.append((len(m.group(1)), 'N', m.group(2), m.group(3)))
            continue
        m = FLD.match(l)
        if m:
            out.append((len(m.group(1)), 'F', m.group(2), m.group(3)))
    return out

SEL = {'bit_select', 'var_select', 'part_select', 'indexed_part_select'}
IDXF = {'vpiIndex', 'vpiExpr', 'vpiExprs', 'vpiLeftRange', 'vpiRightRange',
        'vpiBaseExpr', 'vpiWidthExpr'}

def cells(path):
    L = parse(path)
    n = len(L)
    # field of a node line = nearest preceding line at the SAME indent starting '|'
    fieldof = [None] * n
    for i in range(n):
        if L[i][1] != 'N':
            continue
        d = L[i][0]
        for k in range(i - 1, -1, -1):
            if L[k][0] < d:
                break
            if L[k][0] == d and L[k][1] == 'F':
                fieldof[i] = L[k][2]
                break
    res = {}
    # a hier_path ELEMENT: a node whose enclosing node (indent d-2) is hier_path
    # and whose field is vpiActual.
    def encl(i):
        d = L[i][0]
        for k in range(i - 1, -1, -1):
            if L[k][0] == d - 2 and L[k][1] == 'N':
                return k
            if L[k][0] < d - 2:
                return None
        return None
    for i in range(n):
        if L[i][1] != 'N' or L[i][2] not in SEL:
            continue
        e = encl(i)
        if e is None or L[e][2] != 'hier_path' or fieldof[i] != 'vpiActual':
            continue
        # walk the element's subtree, never through a vpiParent back-link
        d0 = L[i][0]
        j = i + 1
        # skip stack: indent at which we are inside a vpiParent subtree
        skip = None
        inidx = []     # stack of (indent, depth) for index fields
        while j < n and L[j][0] > d0:
            d, t, nm, rest = L[j]
            if skip is not None and d > skip:
                j += 1; continue
            skip = None
            if t == 'F':
                if nm in ('vpiParent', 'vpiInstance', 'vpiTypespec',
                          'vpiActual' if False else '\x00'):
                    skip = d
                j += 1; continue
            # node
            f = fieldof[j]
            if f in ('vpiParent', 'vpiInstance'):
                skip = d; j += 1; continue
            while inidx and inidx[-1][0] >= d:
                inidx.pop()
            if f in IDXF:
                inidx.append((d, (inidx[-1][1] + 1) if inidx else 1))
            if nm == 'ref_obj' and inidx:
                fn = re.sub(r'^\(', '', rest.split(',')[0].strip())
                fn = fn.rstrip(')')
                m = LOC.search(rest)
                loc = f"{m.group(1)}:{m.group(2)}" if m else '?'
                # bound?  look for a |vpiActual: child at d+2
                act = '-'
                k = j + 1
                while k < n and L[k][0] > d:
                    if L[k][0] == d + 2 and L[k][1] == 'F' and L[k][2] == 'vpiActual':
                        if k + 1 < n and L[k + 1][1] == 'N':
                            act = L[k + 1][2]
                        break
                    k += 1
                key = fn
                if __import__('os').environ.get('V143KEY') == 'tail':
                    key = fn.split('::')[-1]
                    loc = loc.split(':')[0]
                res[(key, loc, inidx[-1][1])] = act
            j += 1
    return res

if len(sys.argv) == 2:
    for k, v in sorted(cells(sys.argv[1])):
        pass
    for k in sorted(cells(sys.argv[1])):
        print(f"{k[0]}\t{k[1]}\tD{k[2]}\t{cells.__name__ and ''}", end='')
        print(cells(sys.argv[1])[k] if False else '')
    sys.exit(0)

g = cells(sys.argv[1]); o = cells(sys.argv[2])
gk, ok = set(g), set(o)
agree = [k for k in gk & ok if g[k] == o[k]]
over  = [k for k in gk & ok if g[k] == '-' and o[k] != '-']
under = [k for k in gk & ok if g[k] != '-' and o[k] == '-']
diff  = [k for k in gk & ok if g[k] != o[k] and k not in over and k not in under]
print(f"AGREE {len(agree)}  OURS-OVERBOUND {len(over)}  OURS-UNDERBOUND {len(under)}  "
      f"OTHER-DIFF {len(diff)}  ONLY-GOLDEN {len(gk-ok)}  ONLY-OURS {len(ok-gk)}")
for tag, s in (('OVERBOUND', over), ('UNDERBOUND', under), ('OTHERDIFF', diff),
               ('ONLYGOLD', sorted(gk - ok)), ('ONLYOURS', sorted(ok - gk))):
    for k in sorted(s):
        print(f"  {tag}\t{k[0]}\t{k[1]}\tD{k[2]}\tG={g.get(k,'.')}\tO={o.get(k,'.')}")
