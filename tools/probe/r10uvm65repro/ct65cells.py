#!/usr/bin/env python3
"""r10uvm65 — THE FIELD-POLICY GRID for `<subroutine>.vpiStmt`.

  usage: ct65cells.py <golden.dump> <ours.dump> [name-substring-filter]

Both dumps must already have had `sed 1d` applied (uhdm-dump's first line is the
database path and always differs).

WHAT IT MEASURES, and why each guard is here — every one of them is a trap this
campaign has already paid for:

  * AN OBJECT IS NOT A DUMP OCCURRENCE.  uhdm-dump prints the same object again,
    with fewer fields, under every other parent that references it (vpiParent
    back-references, vpiFunction, vpiMethod, ...).  Each object is therefore
    keyed by (kind, header-span, fullname) and kept at its FULLEST occurrence —
    the occurrence with the most own-child field lines.
  * OWN-CHILD INDENT ONLY.  In uhdm-dump an object header at indent N has its
    own field lines at indent N+2, and each field's target object header ALSO at
    indent N+2.  The same field text two indents deeper belongs to a grandchild.
    Fields are read at exactly N+2 and nowhere else.
  * A SPAN PRESENT ON ONE SIDE ONLY IS `-NOOBJ-`, NEVER AGREEMENT.  A key found
    in one dump and not the other is printed as UNMEASURED so a driver that
    compares nothing can never read as a match.
  * THE STMT TARGET IS REPORTED BY KIND *AND* SPAN *AND* EMPTINESS.  "has a
    vpiStmt" is not the measurement: golden's empty-body `begin` differs from a
    bare statement and from a non-empty begin, and conflating them is how a
    "matching" cell hides a wrong object.

Output columns:
   KEY                 kind@span (fullname)
   G / O                what sits at vpiStmt on each side:
                          -NONE-            no vpiStmt field at all
                          <kind>@<span>*E   a begin/named_begin with NO Stmts
                          <kind>@<span>     anything else
   VERDICT             SAME / DIFF / UNMEASURED
"""
import re
import sys

HDR = re.compile(r'^(\s*)\\_(\w+): (.*)$')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')
SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')


def parse(path):
    """-> {key: {'fields': {name: [targetkey...]}, 'nfields': int}}"""
    lines = open(path, errors='replace').read().split('\n')
    hdr = []          # (indent, key) stack of enclosing object headers
    objs = {}
    # first pass: header line index -> key
    keys = [None] * len(lines)
    for i, ln in enumerate(lines):
        m = HDR.match(ln)
        if not m:
            continue
        ind, kind, rest = len(m.group(1)), m.group(2), m.group(3)
        sp = SPAN.search(rest)
        span = '%s:%s-%s:%s' % sp.groups() if sp else 'nospan'
        nm = rest.split('(')[1].split(')')[0] if '(' in rest else ''
        keys[i] = '%s@%s(%s)' % (kind, span, nm)
    # second pass: own fields at indent+2
    for i, ln in enumerate(lines):
        if keys[i] is None:
            continue
        m = HDR.match(ln)
        ind = len(m.group(1))
        fields = {}
        j = i + 1
        while j < len(lines):
            l2 = lines[j]
            if not l2.strip():
                j += 1
                continue
            mf = FLD.match(l2)
            mh = HDR.match(l2)
            ind2 = len(mf.group(1)) if mf else (len(mh.group(1)) if mh else -1)
            if ind2 < 0 or ind2 <= ind:
                break                      # left this object
            if ind2 == ind + 2 and mf:
                fname, fval = mf.group(2), mf.group(3)
                tgt = None
                if fval == '' and j + 1 < len(lines):
                    mh2 = HDR.match(lines[j + 1])
                    if mh2 and len(mh2.group(1)) == ind + 2:
                        tgt = keys[j + 1]
                fields.setdefault(fname, []).append(tgt if tgt else fval)
            j += 1
        k = keys[i]
        n = sum(len(v) for v in fields.values())
        if k not in objs or n > objs[k]['n']:
            objs[k] = {'f': fields, 'n': n}
    return objs


def stmt_of(objs, k):
    o = objs.get(k)
    if o is None:
        return '-NOOBJ-'
    st = o['f'].get('vpiStmt')
    if not st:
        return '-NONE-'
    if len(st) > 1:
        return 'MULTI(%d)' % len(st)
    t = st[0]
    if not isinstance(t, str) or '@' not in t:
        return 'RAW(%r)' % t
    kind = t.split('@')[0]
    span = t.split('@')[1].split('(')[0]
    tag = '%s@%s' % (kind, span)
    if kind in ('begin', 'named_begin'):
        to = objs.get(t)
        if to is not None and not to['f'].get('vpiStmt'):
            tag += '*E'          # an EMPTY block: no Stmts at all
    return tag


def main():
    g = parse(sys.argv[1])
    o = parse(sys.argv[2])
    filt = sys.argv[3] if len(sys.argv) > 3 else ''
    keys = [k for k in set(g) | set(o)
            if k.startswith(('function@', 'task@')) and filt in k]
    same = diff = unm = 0
    print('%-58s %-26s %-26s %s' % ('KEY', 'GOLDEN.vpiStmt', 'OURS.vpiStmt', 'VERDICT'))
    for k in sorted(keys, key=lambda x: (x.split('(')[1], x)):
        gs, os_ = stmt_of(g, k), stmt_of(o, k)
        if gs == '-NOOBJ-' or os_ == '-NOOBJ-':
            v = 'UNMEASURED'
            unm += 1
        elif gs == os_:
            v = 'SAME'
            same += 1
        else:
            v = 'DIFF'
            diff += 1
        print('%-58s %-26s %-26s %s' % (k[:58], gs, os_, v))
    print('-- subroutines: SAME=%d DIFF=%d UNMEASURED=%d' % (same, diff, unm))


main()
