#!/usr/bin/env python3
"""r10earl46 census — CONSTANT / PARAMETER *value encoding* (INT vs UINT vs
BIN/HEX/OCT) and vpiConstType, BOTH SIDES, DESIGN-WIDE, SPAN-KEYED,
SECTION-SEPARATED.

LHS is ALWAYS golden (Surelog).  RHS is ALWAYS ours.

    usage: census46.py <g.dump> <o.dump>

Both dumps must already have uhdm-dump's first line (the database path)
stripped (`sed 1d`).

WHY IT IS NOT census45.py.  census45 keyed `operation` vpiSize.  The r10earl46
head is a *constant* whose ONLY divergent fields are the VALUE ENCODING
(`INT:0` vs `UINT:0`) and `vpiConstType` (7 vs 9).  Both are read by
constant::Compare (UHDM's generated constant Compare body reads VpiValue,
VpiSize, VpiDecompile, VpiConstType, Typespec).  So this census tallies EVERY
`constant` object in the design, both sides, keyed on
(section, scope path, span, ordinal), and compares the tuple

    (value-encoding prefix, vpiConstType, vpiSize, vpiDecompile)

It ALSO tallies every `parameter` object the same way, because a gen-scope
localparam carries the SAME encoding decision TWICE — once on the parameter's
own VpiValue and once on the param_assign Rhs constant — and a fix that moves
only one of them would trade one divergence for another.

A dump `constant` prints its value as a FIELD NAMED FOR THE ENCODING
(`|INT:0`, `|UINT:0`, `|BIN:0101`, ...), so the encoding is the field name.
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
           'vpiTaskFunc', 'vpiVariables_')
ENC = ('INT', 'UINT', 'BIN', 'HEX', 'OCT', 'DEC', 'STRING', 'REAL', 'SCALAR',
       'TIME')
WANT = ('constant', 'parameter')


def parse(path):
    section = None
    stack = []           # [indent, kind, span, name, pending_field, rec]
    scopestack = []
    objs = {}
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
                # A field line sits at the SAME indent as its owner's CHILDREN
                # (owner indent + 2) -- census45.py paid for this in blood; do
                # NOT use ind+1 here or every field lands on the previous
                # SIBLING instead of the owner.
                ind, name, val = len(m.group(1)), m.group(2), m.group(3)
                close_to(ind)
                if not stack:
                    continue
                owner = stack[-1]
                owner[4] = name
                r = owner[5]
                if r is not None:
                    if name in ENC:
                        r['enc'] = name
                        r['val'] = val.strip()
                    elif name == 'vpiConstType':
                        r['ct'] = val.strip()
                    elif name == 'vpiSize':
                        r['size'] = val.strip()
                    elif name == 'vpiDecompile':
                        r['dec'] = val.strip()
                    elif name == 'vpiFullName':
                        r['full'] = val.strip()
                continue
            m = OBJ.match(line)
            if m:
                ind, kind, rest = len(m.group(1)), m.group(2), m.group(3)
                close_to(ind)
                parent = stack[-1] if stack else None
                pfield = parent[4] if parent else None
                if pfield in BACKREF:
                    continue          # a BACK-reference print, never containment
                sm = SPAN.search(rest)
                span = ('%s:%s-%s:%s' % sm.groups()) if sm else '?'
                nm = rest.split(',')[0].strip()
                rec = None
                if kind in WANT:
                    scope = '/'.join(s[1] for s in scopestack) or '?'
                    base = (section, scope, kind, span, nm)
                    counts[base] += 1
                    key = base + (counts[base],)
                    rec = {'key': key, 'span': span, 'scope': scope,
                           'section': section, 'kind': kind, 'name': nm,
                           'enc': None, 'val': None, 'ct': None,
                           'size': None, 'dec': None, 'full': None,
                           'ownerfield': pfield,
                           'ownerkind': parent[1] if parent else None}
                    objs[key] = rec
                stack.append([ind, kind, span, nm, None, rec])
                if kind in SCOPEKINDS:
                    scopestack.append((ind, nm))
    return objs


def sig(r):
    return (r['enc'], r['ct'], r['size'], r['dec'])


def main():
    g = parse(sys.argv[1])
    o = parse(sys.argv[2])
    for kind in WANT:
        gk = {k: v for k, v in g.items() if v['kind'] == kind}
        ok = {k: v for k, v in o.items() if v['kind'] == kind}
        common = set(gk) & set(ok)
        print('\n================ %s: golden %d  ours %d  '
              'span-matched %d  golden-only %d  ours-only %d' %
              (kind.upper(), len(gk), len(ok), len(common),
               len(set(gk) - set(ok)), len(set(ok) - set(gk))))

        # Q1 ENCODING-ONLY join (the r10earl46 axis)
        j = defaultdict(int)
        for k in common:
            j[(gk[k]['enc'], ok[k]['enc'])] += 1
        print('  Q1 encoding join  golden -> ours   (DIFFERING rows <<<)')
        for k, v in sorted(j.items(), key=lambda kv: -kv[1]):
            print('     %-8s -> %-8s %8d%s' %
                  (k[0], k[1], v, '  <<<' if k[0] != k[1] else ''))

        # Q2 the INT/UINT axis specifically, both directions
        gi = [k for k in common
              if gk[k]['enc'] == 'INT' and ok[k]['enc'] == 'UINT']
        gu = [k for k in common
              if gk[k]['enc'] == 'UINT' and ok[k]['enc'] == 'INT']
        print('  Q2 INT/UINT disagreements:  golden INT / ours UINT = %d   '
              'golden UINT / ours INT = %d' % (len(gi), len(gu)))

        # Q3 by section+file-ish scope, for the golden-INT/ours-UINT population
        for label, pop in (('golden INT -> ours UINT', gi),
                           ('golden UINT -> ours INT', gu)):
            if not pop:
                continue
            print('  Q3 %s: by (section, span, ownerkind.ownerfield)' % label)
            by = defaultdict(int)
            for k in pop:
                by[(gk[k]['section'], gk[k]['span'],
                    '%s.%s' % (gk[k]['ownerkind'], gk[k]['ownerfield']))] += 1
            for k, v in sorted(by.items(), key=lambda kv: -kv[1])[:60]:
                print('     %-12s %-22s %-34s %6d cells' %
                      (k[0], k[1], k[2], v))
            print('     distinct spans: %d   total cells: %d' %
                  (len(set(gk[k]['span'] for k in pop)), len(pop)))
            print('  Q3b sample scopes (up to 12 per span, first 6 spans)')
            spans = sorted(set(gk[k]['span'] for k in pop))
            for sp in spans[:6]:
                ks = [k for k in pop if gk[k]['span'] == sp]
                print('     span %s  (%d cells)' % (sp, len(ks)))
                for k in sorted(ks)[:12]:
                    print('        %-10s %-70s g=%s:%s/ct%s size=%s dec=%s | '
                          'o=%s:%s/ct%s size=%s dec=%s' %
                          (gk[k]['section'], gk[k]['scope'][-70:],
                           gk[k]['enc'], gk[k]['val'], gk[k]['ct'],
                           gk[k]['size'], gk[k]['dec'],
                           ok[k]['enc'], ok[k]['val'], ok[k]['ct'],
                           ok[k]['size'], ok[k]['dec']))

        # Q4 EVERY divergent cell of this kind, by full signature
        s = defaultdict(int)
        for k in common:
            if sig(gk[k]) != sig(ok[k]):
                parts = []
                for f in ('enc', 'ct', 'size', 'dec'):
                    if gk[k][f] != ok[k][f]:
                        parts.append('%s(%s->%s)' % (f, gk[k][f], ok[k][f]))
                s[(gk[k]['section'], ' '.join(parts))] += 1
        print('  Q4 ALL divergent %s cells by signature (top 40)' % kind)
        for k, v in sorted(s.items(), key=lambda kv: -kv[1])[:40]:
            print('     %-12s %-78s %6d' % (k[0], k[1][:78], v))
        print('     TOTAL divergent %s cells: %d' % (kind, sum(s.values())))


if __name__ == '__main__':
    main()
