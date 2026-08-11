#!/usr/bin/env python3
"""ctsprobe.py — read a uhdm-dump and answer, per CLASS VARIABLE, the two
questions law 1 turns on:

  * what SPAN does its class_typespec carry (whole `gc#(T)` text, or the
    generic class NAME TOKEN only)?
  * does that class_typespec carry vpiParameter / vpiParamAssign?

WHY IT IS NOT A GREP.  uhdm-dump prints an object's CHILDREN at some
occurrences and abbreviates it at others, so a single occurrence showing no
`|vpiParameter` proves nothing.  This tool identifies objects by
(kind, name, line:col-endline:endcol) and takes the UNION of what every
occurrence shows, so `hasParam` is "some occurrence printed vpiParameter".
That is the same class of instrument bug pass 52 recorded in its section 1a
(container-priority) and it is pinned by --selftest below.

Commands:
  byvar   <dump>...   class_var -> its typespec's (name, span, hasParam)
  census  <dump>...   histogram of (hasParam, parent kind)
  cell    <dump> <regex>   only class_vars whose name matches
  --selftest          POSITIVE CONTROL: a built-in fixture where the SAME
                      object is printed once with children and once without;
                      asserts hasParam=True (a tool without the union would
                      say False) and asserts an unresolvable typespec reports
                      UNMEASURED rather than silently vanishing.

GUARDS:
  * refuses to report on a dump it parsed to ZERO class_typespec nodes;
  * prints UNMEASURED for any class_var whose typespec cannot be resolved, and
    counts them, so a driver that resolves nothing cannot read as clean;
  * does NOT strip uhdm-dump's first line (the DATABASE PATH) -- feed it a dump
    already passed through `sed '1d'`; it only ever reads `\\_`/`|` lines so a
    stray first line is inert either way.

LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.
"""
import re
import sys

NODE_RE = re.compile(r'^(\s*)\\_(\w+): ?(\(([^)]*)\))?(.*)$')
REL_RE = re.compile(r'^(\s*)\|(\w+):?(.*)$')
LOC_RE = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')


def parse(path):
    """Return (objs, lines).

    objs maps key -> dict(kind, name, loc, rels:set, occurrences:[lineno]).
    key = (kind, name, loc).  loc is '' when the node printed no line info.
    """
    lines = open(path, errors='replace').read().split('\n')
    objs = {}
    stack = []          # (indent, key)
    n = len(lines)
    for i, l in enumerate(lines):
        m = NODE_RE.match(l)
        if m:
            ind = len(m.group(1))
            kind = m.group(2)
            name = m.group(4) or ''
            rest = m.group(5) or ''
            lm = LOC_RE.search(rest)
            loc = ':'.join(lm.groups()) if lm else ''
            key = (kind, name, loc)
            o = objs.setdefault(key, {'kind': kind, 'name': name, 'loc': loc,
                                      'rels': set(), 'occ': []})
            o['occ'].append(i + 1)
            while stack and stack[-1][0] >= ind:
                stack.pop()
            stack.append((ind, key))
            continue
        m = REL_RE.match(l)
        if m:
            ind = len(m.group(1))
            rel = m.group(2)
            # the relation belongs to the node printed at indent ind-2
            while stack and stack[-1][0] >= ind:
                stack.pop()
            if stack:
                objs[stack[-1][1]]['rels'].add(rel)
                # remember relation for the NEXT node line so byvar can walk it
                objs[stack[-1][1]].setdefault('relat', []).append((i + 1, rel))
    return objs, lines


def child_under(lines, objs, occ_line, rel, want_kind=None):
    """From an object occurrence at 1-based occ_line, find the node printed
    directly under its `|rel:` child marker.  Returns a key or None."""
    m = NODE_RE.match(lines[occ_line - 1])
    if not m:
        return None
    ind = len(m.group(1))
    j = occ_line          # 0-based index of next line
    while j < len(lines):
        l = lines[j]
        mr = REL_RE.match(l)
        if mr and len(mr.group(1)) == ind + 2:
            if mr.group(2) == rel:
                mn = NODE_RE.match(lines[j + 1]) if j + 1 < len(lines) else None
                if mn:
                    lm = LOC_RE.search(mn.group(5) or '')
                    loc = ':'.join(lm.groups()) if lm else ''
                    k = (mn.group(2), mn.group(4) or '', loc)
                    if want_kind is None or mn.group(2) == want_kind:
                        return k
            j += 1
            continue
        if mr and len(mr.group(1)) > ind + 2:
            j += 1
            continue
        mn = NODE_RE.match(l)
        if mn and len(mn.group(1)) > ind:
            j += 1
            continue
        break
    return None


def resolve_var_ts(lines, objs, vkey):
    """class_var -> the class_typespec its vpiTypespec/ref_typespec points at."""
    for occ in objs[vkey]['occ']:
        rt = child_under(lines, objs, occ, 'vpiTypespec')
        if not rt or rt not in objs:
            continue
        for rocc in objs[rt]['occ']:
            act = child_under(lines, objs, rocc, 'vpiActual')
            if act:
                return act
    return None


def report(path, mode, pat=None):
    objs, lines = parse(path)
    cts = [k for k in objs if k[0] == 'class_typespec']
    print('==', path, ' class_typespec objects:', len(cts))
    if not cts:
        print('   REFUSING TO REPORT: parsed 0 class_typespec objects')
        return 1
    if mode == 'census':
        import collections
        c = collections.Counter()
        for k in cts:
            c[('vpiParameter' in objs[k]['rels'])] += 1
        for kk, v in sorted(c.items(), key=lambda x: str(x[0])):
            print('   hasParam=%-5s %d' % (kk, v))
        return 0
    rx = re.compile(pat) if pat else None
    unmeasured = 0
    shown = 0
    rows = []
    for k in objs:
        if k[0] != 'class_var':
            continue
        if rx and not rx.search(k[1]):
            continue
        ts = resolve_var_ts(lines, objs, k)
        if ts is None or ts not in objs:
            rows.append((k[1], 'UNMEASURED', '', ''))
            unmeasured += 1
            continue
        rows.append((k[1], ts[1], ts[2],
                     'vpiParameter' in objs[ts]['rels']))
        shown += 1
    for r in sorted(rows):
        print('   %-52s ts=%-26s span=%-22s hasParam=%s' % r)
    print('   ---- resolved=%d UNMEASURED=%d' % (shown, unmeasured))
    return 0


FIXTURE = r"""design: (work@t)
|vpiVariables:
\_class_var: (p::h::v), line:9:5, endln:9:9
  |vpiTypespec:
  \_ref_typespec: (p::h::v)
    |vpiActual:
    \_class_typespec: (gc), line:9:1, endln:9:3
|vpiVariables:
\_class_var: (p::h::w), line:10:5, endln:10:9
\_class_typespec: (gc), line:9:1, endln:9:3
  |vpiName:gc
  |vpiParameter:
  \_type_parameter: (gc.T), line:1:1, endln:1:2
"""


def selftest():
    import tempfile
    import os
    fd, p = tempfile.mkstemp(suffix='.dump')
    os.write(fd, FIXTURE.encode())
    os.close(fd)
    objs, lines = parse(p)
    ok = True
    kv = ('class_var', 'p::h::v', '9:5:9:9')
    kw = ('class_var', 'p::h::w', '10:5:10:9')
    assert kv in objs, 'fixture class_var v not parsed'
    assert kw in objs, 'fixture class_var w not parsed'
    ts = resolve_var_ts(lines, objs, kv)
    if ts != ('class_typespec', 'gc', '9:1:9:3'):
        print('SELFTEST FAIL: v typespec resolved to', ts); ok = False
    # THE UNION CELL: the occurrence reached through the class_var prints NO
    # children; only the flat listing shows vpiParameter.  A tool that read
    # one occurrence would answer False here.
    if 'vpiParameter' not in objs[ts]['rels']:
        print('SELFTEST FAIL: union of occurrences lost vpiParameter'); ok = False
    # THE UNMEASURED CELL: w has no vpiTypespec at all.
    if resolve_var_ts(lines, objs, kw) is not None:
        print('SELFTEST FAIL: w should be UNMEASURED'); ok = False
    os.unlink(p)
    print('SELFTEST', 'PASS' if ok else 'FAIL')
    return 0 if ok else 1


if __name__ == '__main__':
    if '--selftest' in sys.argv:
        sys.exit(selftest())
    mode = sys.argv[1]
    if mode == 'cell':
        sys.exit(report(sys.argv[2], 'cell', sys.argv[3]))
    rc = 0
    for f in sys.argv[2:]:
        rc |= report(f, mode)
    sys.exit(rc)
