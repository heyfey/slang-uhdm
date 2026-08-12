#!/usr/bin/env python3
"""r10earl33 — THE PER-CELL CALL-ARGUMENT TABLE, **VIEW-KEYED**.

r10earl32's `cells32.py` keys a row on (argument start span, call kind, call
name, call span) and DROPS every later row with the same key.  That is exactly
the wrong dedup for this pass: a generate body is emitted TWICE — once in the
module's DEF listing (`uhdmallModules`) and once per ELABORATED gen_scope
(`uhdmtopModules`) — and r10earl33's whole defect lives in ONE of those two
views.  Read with cells32.py, v4_more's 30:19 prints a single row and the
elaborated instances, which already agree with golden, are invisible.

So the key here carries the VIEW (the top-level `|uhdmXXX:` section the object
sits under) and an OCCURRENCE INDEX inside it, and every occurrence prints.

Fields per row:  KIND | span | decompile-or-name | vpiParent kind | vpiTypespec

GOLDEN IS ALWAYS argv[1].

Stub discipline (inherited from census32.py/cells32.py, and re-proved by the
selfcheck): `|vpiParent:` / `|vpiFunction:` / `|vpiTask:` print a
back-reference STUB — never descended into, never counted as a call or an
argument.  A `|vpiTypespec:` -> `\\_ref_typespec:` child IS a real object and
its own `|vpiActual:` is read one level deeper.

usage:  cells33.py GOLDEN.dump OURS.dump [--only LINE[,LINE...]] [--diffonly]
        cells33.py --selfcheck
"""
import re
import sys

OBJ = re.compile(r'^(\s*)\\_([A-Za-z_0-9]+): (.*)$')
FLD = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')
LOC = re.compile(r'line:(\d+):(\d+)(?:, endln:(\d+):(\d+))?')
TOPSEC = re.compile(r'^\|(uhdm[A-Za-z_0-9]+):\s*$')
CALLS = ('func_call', 'task_call', 'method_func_call', 'method_task_call',
         'sys_func_call', 'sys_task_call')
STUBF = ('vpiParent', 'vpiFunction', 'vpiTask')


class N:
    __slots__ = ('type', 'field', 'sspan', 'span', 'name', 'kids', 'stub',
                 'f', 'view')

    def __init__(self, t, fld, raw, view):
        self.type, self.field, self.view = t, fld, view
        m = LOC.search(raw)
        if m:
            self.sspan = '%s:%s' % (m.group(1), m.group(2))
            self.span = self.sspan + '-' + ('%s:%s' % (m.group(3), m.group(4))
                                            if m.group(3) else '?')
        else:
            self.sspan, self.span = '?', '?'
        mn = re.match(r'^\(([^)]*)\)', raw.strip())
        self.name = mn.group(1) if mn else ''
        self.kids = []
        self.stub = fld in STUBF
        self.f = {}


def parse(path):
    root = N('DESIGN', '', '', '')
    stack = [(-2, root)]
    cf = {}
    calls = []
    view = '<none>'
    with open(path, 'rt', errors='replace') as fh:
        for line in fh:
            line = line.rstrip('\n')
            m = TOPSEC.match(line)
            if m:
                view = m.group(1)
                continue
            m = OBJ.match(line)
            if m:
                ind = len(m.group(1))
                while stack and stack[-1][0] >= ind:
                    stack.pop()
                p = stack[-1][1] if stack else root
                n = N(m.group(2), cf.get(id(p), ''), m.group(3), view)
                p.kids.append(n)
                if n.type in CALLS and not n.stub:
                    calls.append(n)
                stack.append((ind, n))
                continue
            m = FLD.match(line)
            if m:
                ind = len(m.group(1))
                while stack and stack[-1][0] >= ind:
                    stack.pop()
                o = stack[-1][1] if stack else root
                cf[id(o)] = m.group(2)
                if m.group(2) in ('vpiDecompile', 'vpiSize', 'vpiConstType',
                                  'vpiFullName', 'vpiName'):
                    o.f[m.group(2)] = m.group(3)
    return calls


def kid(n, field):
    for k in n.kids:
        if k.field == field:
            return k
    return None


def ts_of(a):
    t = kid(a, 'vpiTypespec')
    if t is None:
        return '<bare>'
    act = kid(t, 'vpiActual')
    return '%s(%s)->%s' % (t.type, t.f.get('vpiFullName', ''),
                           ('%s@%s' % (act.type, act.span)) if act else '<null>')


def rows(path):
    out = {}
    seen = {}
    for c in parse(path):
        for a in c.kids:
            if a.field != 'vpiArgument':
                continue
            base = (c.view, a.sspan, c.type,
                    c.name or c.f.get('vpiName', ''), c.sspan)
            n = seen.get(base, 0)
            seen[base] = n + 1
            par = kid(a, 'vpiParent')
            out[base + (n,)] = (a.type, a.span, a.f.get('vpiDecompile', ''),
                                par.type if par else '<none>', ts_of(a),
                                a.name or a.f.get('vpiName', ''),
                                a.f.get('vpiSize', ''))
    return out


SELF = ("|uhdmallModules:\n"
        "\\_module_inst: work@m (work@m), line:1:1, endln:9:10\n"
        "  |vpiRhs:\n"
        "  \\_func_call: (f), line:5:10, endln:5:20\n"
        "    |vpiParent:\n"
        "    \\_cont_assign: , line:5:3, endln:5:20\n"
        "    |vpiArgument:\n"
        "    \\_ref_obj: (p::P), line:5:12, endln:5:18\n"
        "      |vpiParent:\n"
        "      \\_func_call: (f), line:5:10, endln:5:20\n"
        "      |vpiName:p::P\n"
        "    |vpiName:f\n"
        "|uhdmtopModules:\n"
        "\\_module_inst: work@t (work@t), line:1:1, endln:9:10\n"
        "  |vpiRhs:\n"
        "  \\_func_call: (f), line:5:10, endln:5:20\n"
        "    |vpiParent:\n"
        "    \\_cont_assign: , line:5:3, endln:5:20\n"
        "    |vpiArgument:\n"
        "    \\_constant: , line:5:12, endln:5:18\n"
        "      |vpiParent:\n"
        "      \\_func_call: (f), line:5:10, endln:5:20\n"
        "      |vpiDecompile:12'h380\n"
        "      |vpiTypespec:\n"
        "      \\_ref_typespec: (work@t)\n"
        "        |vpiParent:\n"
        "        \\_constant: , line:5:12, endln:5:18\n"
        "        |vpiFullName:work@t\n"
        "        |vpiActual:\n"
        "        \\_logic_typespec: , line:3:54, endln:3:59\n"
        "      |vpiConstType:5\n"
        "    |vpiName:f\n")


def main():
    if '--selfcheck' in sys.argv:
        import os
        import tempfile
        fd, p = tempfile.mkstemp(suffix='.dump')
        os.write(fd, SELF.encode())
        os.close(fd)
        r = rows(p)
        os.unlink(p)
        views = sorted(k[0] for k in r)
        kinds = sorted(v[0] for v in r.values())
        tss = sorted(v[4] for v in r.values())
        ok = (len(r) == 2 and views == ['uhdmallModules', 'uhdmtopModules']
              and kinds == ['constant', 'ref_obj']
              and tss == ['<bare>',
                          'ref_typespec(work@t)->logic_typespec@3:54-3:59'])
        print('SELFCHECK rows=%d views=%s kinds=%s' % (len(r), views, kinds))
        print('SELFCHECK: %s (the SAME argument span in the DEF listing and in '
              'the ELABORATED instance must stay TWO rows — cells32.py '
              'collapses them and hides exactly this pass\'s defect; the '
              'vpiParent back-reference stub must not be read as a second call '
              'or a second argument; the ref_typespec under |vpiTypespec: must '
              'be found and its own |vpiActual: read one level deeper)'
              % ('PASS' if ok else 'FAIL'))
        sys.exit(0 if ok else 1)

    g = rows(sys.argv[1])
    o = rows(sys.argv[2])
    only = None
    if '--only' in sys.argv:
        only = set(sys.argv[sys.argv.index('--only') + 1].split(','))
    diffonly = '--diffonly' in sys.argv
    keys = sorted(set(g) | set(o),
                  key=lambda k: (int(k[1].split(':')[0]),
                                 int(k[1].split(':')[1]), k[0], k[5]))
    print('%-11s %-4s %-13s %-14s | %-52s | %s' %
          ('arg@', '#', 'call', 'view', 'GOLDEN', 'OURS'))
    ndiff = 0
    for k in keys:
        if only and k[1].split(':')[0] not in only:
            continue
        gv, ov = g.get(k), o.get(k)

        def fmt(v):
            if v is None:
                return '<ABSENT>'
            return '%s %s %s p=%s ts=%s' % (v[0], v[1], v[2] or v[5], v[3],
                                            v[4])
        same = gv == ov
        if not same:
            ndiff += 1
        if diffonly and same:
            continue
        print('%-11s %-4s %-13s %-14s | %-52s | %s%s' %
              (k[1], k[5], (k[3] or '')[:13], k[0].replace('uhdm', ''),
               fmt(gv), fmt(ov), '' if same else '   <== DIFF'))
    print('CELLS total=%d cell-diffs=%d' % (len(keys), ndiff))


if __name__ == '__main__':
    main()
