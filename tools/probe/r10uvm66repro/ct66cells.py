#!/usr/bin/env python3
"""r10uvm66 — THE STATEMENT-LIST / VAR-OWNER GRID.

  usage: ct66cells.py <golden.dump> <ours.dump> [name-substring-filter]

Both dumps must already have had `sed 1d` applied (uhdm-dump's first line is the
database path and always differs).

TWO tables, because the r10uvm66 head is TWO fields of ONE mechanism and a
driver that measured only one of them would have called a half fix green:

  TABLE A — the BODY SIGNATURE of every function/task: the ORDERED list of
            statements in its vpiStmt, one level down (`begin[a@s, b@s]`), so a
            SURPLUS or MISSING list element is visible as an element, not as a
            count.  "How many statements" is not the measurement: an extra
            `assignment` in slot 0 and a missing `return_stmt` in slot 2 are
            different defects and both must show.
  TABLE B — the vpiParent of every VARIABLE object: an emitter that builds a
            statement for a declaration initializer also RE-PARENTS the variable
            onto that statement, and golden keeps the variable on the BLOCK.
            Measured separately, because a patch can fix the list and leave the
            parent wrong (that is exactly the r10uvm66 head's second half).

GUARDS — each an ops trap this campaign has already paid for:

  * AN OBJECT IS NOT A DUMP OCCURRENCE.  uhdm-dump reprints the same object,
    with fewer fields, under every other parent that references it.  Objects are
    keyed and kept at their FULLEST occurrence (most own-child field lines).
  * OWN-CHILD INDENT ONLY.  A header at indent N has its own field lines at
    N+2; the same field text two indents deeper belongs to a grandchild.
  * SUBROUTINES ARE KEYED BY KIND+FULLNAME, **NOT** BY SPAN.  § 65 residue 3
    (golden collapses a `virtual`-led function's span onto the keyword) would
    otherwise key half the interesting cells UNMEASURED and hide a real DIFF
    behind a span law this pass does not own.  The span is printed in its own
    column so a span disagreement is still SEEN, just not fatal to the row.
  * VARIABLES ARE KEYED BY KIND+FULLNAME for the same reason.
  * A KEY PRESENT ON ONE SIDE ONLY IS `-NOOBJ-` AND READS UNMEASURED, never
    agreement: a driver that compares nothing must not read as perfection.
"""
import re
import sys

HDR = re.compile(r'^(\s*)\\_(\w+): (.*)$')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')
SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')

VARKINDS = ('class_var', 'logic_var', 'int_var', 'integer_var', 'byte_var',
            'shortint_var', 'longint_var', 'string_var', 'array_var',
            'struct_var', 'enum_var', 'bit_var', 'real_var', 'time_var',
            'packed_array_var', 'union_var', 'chandle_var', 'short_real_var')

# vpiStmt is the statement list on begin/named_begin/function/task; a fork uses
# vpiStmt too.  These are the only fields walked for TABLE A.
LISTFLD = 'vpiStmt'


def parse(path):
    """-> (objs, keys) where objs[key] = {'f': {field: [targetkey|text]},
                                          'n': nfields, 'hdr': fullkey}"""
    lines = open(path, errors='replace').read().split('\n')
    keys = [None] * len(lines)
    spans = [None] * len(lines)
    for i, ln in enumerate(lines):
        m = HDR.match(ln)
        if not m:
            continue
        kind, rest = m.group(2), m.group(3)
        sp = SPAN.search(rest)
        span = '%s:%s-%s:%s' % sp.groups() if sp else 'nospan'
        nm = rest.split('(')[1].split(')')[0] if '(' in rest else ''
        keys[i] = '%s|%s' % (kind, nm)
        spans[i] = span
    objs = {}
    for i, ln in enumerate(lines):
        if keys[i] is None:
            continue
        ind = len(HDR.match(ln).group(1))
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
                break
            if ind2 == ind + 2 and mf:
                fname, fval = mf.group(2), mf.group(3)
                tgt = None
                if fval == '' and j + 1 < len(lines):
                    mh2 = HDR.match(lines[j + 1])
                    if mh2 and len(mh2.group(1)) == ind + 2:
                        tgt = (keys[j + 1], spans[j + 1])
                fields.setdefault(fname, []).append(tgt if tgt else fval)
            j += 1
        k = (keys[i], spans[i])
        n = sum(len(v) for v in fields.values())
        if k not in objs or n > objs[k]['n']:
            objs[k] = {'f': fields, 'n': n}
    # collapse to kind|fullname, keeping the FULLEST occurrence, and remember
    # every span seen for that name so a span disagreement stays visible.
    byname = {}
    for (k, span), v in objs.items():
        e = byname.get(k)
        if e is None or v['n'] > e[0]['n']:
            byname[k] = (v, span)
    return byname, objs


def sig(byname, objs, tgt, depth):
    """Render a statement-subtree signature: kind@span, and for a block the
    ORDERED list of its own statements."""
    if tgt is None:
        return '-'
    k, span = tgt
    kind = k.split('|')[0]
    s = '%s@%s' % (kind, span)
    if depth <= 0:
        return s
    o = objs.get((k, span)) or (byname.get(k) or (None,))[0]
    if o is None:
        return s
    if kind in ('begin', 'named_begin', 'fork', 'named_fork'):
        kids = [c for c in o['f'].get(LISTFLD, []) if isinstance(c, tuple)]
        return '%s[%s]' % (s, ', '.join(sig(byname, objs, c, depth - 1)
                                        for c in kids))
    return s


def body_of(byname, objs, k):
    e = byname.get(k)
    if e is None:
        return '-NOOBJ-', '-'
    o, span = e
    st = [c for c in o['f'].get(LISTFLD, []) if isinstance(c, tuple)]
    if not st:
        return ('-NONE-' if LISTFLD not in o['f'] else '-NULLSTMT-'), span
    if len(st) > 1:
        return 'MULTI(%d)' % len(st), span
    return sig(byname, objs, st[0], 2), span


def parent_of(byname, k):
    e = byname.get(k)
    if e is None:
        return '-NOOBJ-'
    p = e[0]['f'].get('vpiParent')
    if not p:
        return '-NOPARENT-'
    t = p[0]
    if not isinstance(t, tuple):
        return 'RAW(%r)' % (t,)
    return '%s@%s' % (t[0].split('|')[0], t[1])


def table(title, keys, getg, geto, extra=None):
    same = diff = unm = 0
    print()
    print('== %s' % title)
    print('%-42s %-40s %-40s %s' % ('KEY', 'GOLDEN', 'OURS', 'VERDICT'))
    for k in keys:
        gv, ov = getg(k), geto(k)
        if gv == '-NOOBJ-' or ov == '-NOOBJ-':
            v, unm = 'UNMEASURED', unm + 1
        elif gv == ov:
            v, same = 'SAME', same + 1
        else:
            v, diff = 'DIFF', diff + 1
        note = extra(k) if extra else ''
        print('%-42s %-40s %-40s %s%s' % (k[:42], gv[:40], ov[:40], v, note))
    print('-- %s: SAME=%d DIFF=%d UNMEASURED=%d' % (title, same, diff, unm))
    return same, diff, unm


def main():
    gb, go_ = parse(sys.argv[1])
    ob, oo = parse(sys.argv[2])
    filt = sys.argv[3] if len(sys.argv) > 3 else ''

    subs = sorted(k for k in set(gb) | set(ob)
                  if k.split('|')[0] in ('function', 'task') and filt in k)
    ga = {}
    oa = {}
    for k in subs:
        ga[k] = body_of(gb, go_, k)
        oa[k] = body_of(ob, oo, k)

    def spannote(k):
        gs, os_ = ga[k][1], oa[k][1]
        return '' if gs == os_ else '   [own-span G=%s O=%s]' % (gs, os_)

    a = table('TABLE A — subroutine BODY SIGNATURE (ordered statement list)',
              subs, lambda k: ga[k][0], lambda k: oa[k][0], spannote)

    vars_ = sorted(k for k in set(gb) | set(ob)
                   if k.split('|')[0] in VARKINDS and filt in k)
    b = table('TABLE B — VARIABLE vpiParent',
              vars_, lambda k: parent_of(gb, k), lambda k: parent_of(ob, k))

    print()
    print('== TOTALS  A(body): SAME=%d DIFF=%d UNM=%d   '
          'B(varparent): SAME=%d DIFF=%d UNM=%d' % (a + b))


main()
