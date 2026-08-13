#!/usr/bin/env python3
"""r10uvm72repro/ct72sites.py — list every FULL print of a named call object with
its DUMP LINE NUMBER and its whole ancestor chain, marked BOUND/UNBOUND on the
link field.  ONE SIDE PER RUN.

The census (ct72cen.py) merges prints; this one deliberately does NOT, because
the divergence this pass decodes is BETWEEN THE PRINTS OF ONE CALL (def view vs
elaborated view), and a merge would hide exactly that.

usage: ct72sites.py <dump> <name> [--kinds ...] [--linkfield vpiFunction]
                    [--only unbound|bound] [--chain]
"""
import re
import sys
import argparse

OBJ = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?(.*)$')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')
SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')

ap = argparse.ArgumentParser()
ap.add_argument('dump')
ap.add_argument('name')
ap.add_argument('--kinds', default='func_call,method_func_call')
ap.add_argument('--linkfield', default='vpiFunction')
ap.add_argument('--only', default='all')
ap.add_argument('--chain', action='store_true')
ap.add_argument('--depth', type=int, default=4)
a = ap.parse_args()
kinds = set(a.kinds.split(','))

stack = []
openc = []
out = []


def commit(oc):
    ind, key, flds, anc, lno, tgt = oc
    if not flds:
        return                      # back-reference header, not a print
    # A PRESENT link is not a CORRECT link: this pass's whole defect is a call
    # bound to the WRONG callee, which a presence test reads as green.  The
    # TARGET's name is therefore part of the status.
    st = ('BOUND:' + (tgt or '?')) if a.linkfield in flds else 'UNBOUND'
    out.append((lno, st, key, anc))


for lno, ln in enumerate(open(a.dump, errors='replace'), 1):
    ln = ln.rstrip('\n')
    m = OBJ.match(ln)
    if m:
        ind = len(m.group(1))
        kind, name, rest = m.group(2), m.group(3) or '', m.group(4)
        sp = SPAN.search(rest)
        span = ('%s:%s-%s:%s' % sp.groups()) if sp else '?'
        while stack and stack[-1][0] >= ind:
            stack.pop()
        for oc in [o for o in openc if o[0] >= ind]:
            commit(oc)
        openc = [o for o in openc if o[0] < ind]
        stack.append((ind, kind, name, span))
        if kind in kinds and name == a.name:
            anc = tuple((s[1], s[2], s[3]) for s in stack[:-1])
            openc.append([ind, (kind, name, span), set(), anc, lno, None])
        # the link's TARGET is the object printed one level under the call's
        # own `|vpiFunction:` field line
        for oc in openc:
            if ind == oc[0] + 2 and oc[5] == '<pending>':
                oc[5] = name or kind
        continue
    m = FLD.match(ln)
    if m:
        ind, fld = len(m.group(1)), m.group(2)
        for oc in openc:
            if ind == oc[0] + 2:
                oc[2].add(fld)
                if fld == a.linkfield:
                    oc[5] = '<pending>'
for oc in openc:
    commit(oc)

n = 0
for lno, st, key, anc in out:
    if a.only != 'all' and not st.lower().startswith(a.only):
        continue
    n += 1
    ch = ' < '.join('%s(%s)' % (k, nm) for k, nm, sp in reversed(anc))
    if not a.chain:
        ch = ' < '.join('%s(%s)' % (k, nm)
                        for k, nm, sp in reversed(anc[-a.depth:]))
    print('%8d %-8s %-10s %-18s %s' % (lno, st, key[0], key[2], ch))
print('TOTAL prints listed: %d (of %d full prints)' % (n, len(out)))
