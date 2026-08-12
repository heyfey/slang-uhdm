#!/usr/bin/env python3
"""r10uvm58repro/vcells.py — THE ARM CELL TABLE for VARIABLE-CLASS questions.

One cell per VARIABLE object in a uhdm-dump, keyed on (vpiFullName-or-name,
span, the FIELD it hangs off, the KIND of the node it hangs off).  The cell's
VALUE is the object's UHDM class (int_var / ref_var / ...) plus the two fields
this pass cares about, read at the object's OWN CHILD DEPTH (header indent + 2)
and NEVER anywhere in its subtree:

    S   = |vpiSigned:1 present at own child depth
    ts= = the span of the typespec the object's own ref_typespec resolves to
          (vpiTypespec -> ref_typespec -> vpiActual -> <typespec>), so the
          TYPESPEC-SHARING half of the law is visible per cell.

  usage: vcells.py <g.dump> <o.dump> [name-substring-filter]

GOLDEN IS ALWAYS THE FIRST ARGUMENT (LHS is always golden(Surelog); RHS is
always ours).  Both dumps must already have uhdm-dump's first line (the
DATABASE PATH) stripped.

WHY OWN CHILD DEPTH: `|vpiSigned:1` also appears under the object's own
TYPESPEC child, and a subtree grep counts those — which is exactly how a
"golden does not stamp vpiSigned" claim gets made about a typespec that does.
An object is NOT a dump occurrence: identical (kind,name,span) lines are
COUNTED, and a multiplicity change is a differing cell.

GUARD: a missing or empty input is exit 6, never an empty (and therefore
"equal") table.  The last line — DIFFERING CELLS — is the arm's verdict.
"""
import collections
import re
import sys

HDR = re.compile(r'^(\s*)\\_(\w+): (\([^)]*\))?,? ?(?:file:\S+, )?(line:\d+:\d+, endln:\d+:\d+)?')
FIELDLBL = re.compile(r'^(\s*)\|(\w+):\s*$')
ANYFIELD = re.compile(r'^(\s*)\|(\w+):(.*)$')
VARKIND = re.compile(r'^\w*_var$|^io_decl$')


def parse(path):
    lines = open(path).read().split('\n')
    if len(lines) < 2:
        sys.exit('NO_OUTPUT: %s has no content (exit 6)' % path)
    stack = []
    fieldat = {}
    cells = []
    for i, ln in enumerate(lines):
        mf = FIELDLBL.match(ln)
        if mf:
            fieldat[len(mf.group(1))] = mf.group(2)
            continue
        m = HDR.match(ln)
        if not m:
            continue
        ind = len(m.group(1))
        kind = m.group(2)
        name = (m.group(3) or '()')[1:-1]
        span = (m.group(4) or '').replace('line:', '').replace(' endln:', '-')
        while stack and stack[-1][0] >= ind:
            stack.pop()
        parentkind = stack[-1][1] if stack else '<root>'
        field = fieldat.get(ind, '?')
        stack.append((ind, kind, name))
        if not VARKIND.match(kind):
            continue
        # own child depth == ind + 2
        signed = False
        tsspan = '-'
        j = i + 1
        while j < len(lines):
            l2 = lines[j]
            if not l2.strip():
                j += 1
                continue
            ind2 = len(l2) - len(l2.lstrip())
            if ind2 <= ind:
                break
            if ind2 == ind + 2:
                a = ANYFIELD.match(l2)
                if a and a.group(2) == 'vpiSigned':
                    signed = True
                if a and a.group(2) in ('vpiTypespec', 'vpiTypedef'):
                    # the ref_typespec header is the next header line; walk its
                    # own children for vpiActual, then take the actual's span
                    k = j + 1
                    while k < len(lines):
                        mh = HDR.match(lines[k])
                        if mh and len(mh.group(1)) == ind + 2:
                            base = ind + 2
                            for q in range(k + 1, len(lines)):
                                l3 = lines[q]
                                if not l3.strip():
                                    continue
                                ind3 = len(l3) - len(l3.lstrip())
                                if ind3 <= base:
                                    break
                                a3 = ANYFIELD.match(l3)
                                if ind3 == base + 2 and a3 and a3.group(2) == 'vpiActual':
                                    mh2 = HDR.match(lines[q + 1]) if q + 1 < len(lines) else None
                                    if mh2:
                                        tsspan = '%s@%s' % (
                                            mh2.group(2),
                                            (mh2.group(4) or 'noloc').replace('line:', '').replace(' endln:', '-'))
                                    break
                            break
                        k += 1
            j += 1
        cells.append((name, span, field, parentkind, kind, signed, tsspan))
    return cells


def main():
    if len(sys.argv) < 3:
        sys.exit('usage: vcells.py <g.dump> <o.dump> [filter]')
    filt = sys.argv[3] if len(sys.argv) > 3 else ''
    gc = [c for c in parse(sys.argv[1]) if filt in c[0]]
    oc = [c for c in parse(sys.argv[2]) if filt in c[0]]
    if not gc and not oc:
        sys.exit('NO_CELLS: filter %r matched nothing on either side (exit 6)' % filt)

    def bag(cs):
        d = collections.defaultdict(collections.Counter)
        for n, s, f, pk, k, sg, ts in cs:
            d[(n, s, f, pk)]['%s%s ts=%s' % (k, ',S' if sg else '', ts)] += 1
        return d
    gm, om = bag(gc), bag(oc)
    allk = sorted(set(gm) | set(om))
    print('GOLDEN(LHS)=%s  OURS(RHS)=%s' % (sys.argv[1], sys.argv[2]))
    print('golden var objects=%d  ours var objects=%d  distinct cells=%d'
          % (len(gc), len(oc), len(allk)))
    print('%-44s %-16s %-13s %-13s %-34s %-34s %s'
          % ('NAME', 'SPAN', 'FIELD', 'PARENT-KIND', 'GOLDEN', 'OURS', ''))
    diff = 0
    for k in allk:
        g, o = gm.get(k), om.get(k)

        def fmt(c):
            if c is None:
                return 'ABSENT'
            return ' + '.join('%s%s' % (v, ('x%d' % n) if n > 1 else '')
                              for v, n in sorted(c.items()))
        gs, os_ = fmt(g), fmt(o)
        tag = ''
        if gs != os_:
            diff += 1
            tag = 'DIFF'
        print('%-44s %-16s %-13s %-13s %-34s %-34s %s'
              % (k[0][-44:], k[1], k[2], k[3], gs, os_, tag))
    print('S = vpiSigned at own child depth;  ts= the typespec its ref_typespec resolves to')
    print('DIFFERING CELLS: %d / %d' % (diff, len(allk)))


main()
