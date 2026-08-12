#!/usr/bin/env python3
"""r10earl32 — THE PER-CELL CALL-ARGUMENT TABLE.

Prints EVERY subroutine-call argument of an arm, BOTH SIDES, multiplicity kept,
with the four fields this pass's law is made of:

    object KIND | span | vpiDecompile | vpiParent kind | vpiTypespec -> actual

GOLDEN IS ALWAYS argv[1].  Rows are keyed on the argument's START span, because
the fold and the ref disagree about the END span by construction (golden folds
the whole `pk::P` text, our func-call-arg ref spans the `pk::` qualifier alone).

Stub discipline as census32.py: `|vpiParent:` / `|vpiFunction:` / `|vpiTask:`
print a back-reference STUB, never descended into, never counted as a call.
A `|vpiTypespec:` -> `\\_ref_typespec:` child, by contrast, is a REAL object and
its own `|vpiActual:` child is read one level deeper.

usage:  cells32.py GOLDEN.dump OURS.dump [--only LINE[,LINE...]]
        cells32.py --selfcheck
"""
import re
import sys

OBJ = re.compile(r'^(\s*)\\_([A-Za-z_0-9]+): (.*)$')
FLD = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')
LOC = re.compile(r'line:(\d+):(\d+)(?:, endln:(\d+):(\d+))?')
CALLS = ('func_call', 'task_call', 'method_func_call', 'method_task_call',
         'sys_func_call', 'sys_task_call')
STUBF = ('vpiParent', 'vpiFunction', 'vpiTask')


class N:
    __slots__ = ('type', 'field', 'sspan', 'span', 'name', 'kids', 'stub', 'f')

    def __init__(self, t, fld, raw):
        self.type, self.field = t, fld
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
    root = N('DESIGN', '', '')
    stack = [(-2, root)]
    cf = {}
    calls = []
    with open(path, 'rt', errors='replace') as fh:
        for line in fh:
            line = line.rstrip('\n')
            m = OBJ.match(line)
            if m:
                ind = len(m.group(1))
                while stack and stack[-1][0] >= ind:
                    stack.pop()
                p = stack[-1][1] if stack else root
                n = N(m.group(2), cf.get(id(p), ''), m.group(3))
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
    for c in parse(path):
        for a in c.kids:
            if a.field != 'vpiArgument':
                continue
            k = (a.sspan, c.type, c.name or c.f.get('vpiName', ''), c.sspan)
            if k in out:
                continue
            par = kid(a, 'vpiParent')
            out[k] = (a.type, a.span, a.f.get('vpiDecompile', ''),
                      par.type if par else '<none>', ts_of(a),
                      a.name or a.f.get('vpiName', ''))
    return out


def main():
    if '--selfcheck' in sys.argv:
        import tempfile
        import os
        txt = ("\\_module_inst: work@m (work@m), line:1:1, endln:9:10\n"
               "  |vpiRhs:\n"
               "  \\_func_call: (f), line:5:10, endln:5:20\n"
               "    |vpiParent:\n"
               "    \\_cont_assign: , line:5:3, endln:5:20\n"
               "    |vpiArgument:\n"
               "    \\_constant: , line:5:12, endln:5:18\n"
               "      |vpiParent:\n"
               "      \\_param_assign: , line:2:5, endln:2:9\n"
               "      |vpiDecompile:12'h380\n"
               "      |vpiTypespec:\n"
               "      \\_ref_typespec: (work@m)\n"
               "        |vpiParent:\n"
               "        \\_constant: , line:5:12, endln:5:18\n"
               "        |vpiFullName:work@m\n"
               "        |vpiActual:\n"
               "        \\_logic_typespec: , line:3:54, endln:3:59\n"
               "      |vpiConstType:5\n"
               "    |vpiName:f\n")
        fd, p = tempfile.mkstemp(suffix='.dump')
        os.write(fd, txt.encode())
        os.close(fd)
        r = rows(p)
        os.unlink(p)
        vals = list(r.values())
        ok = (len(r) == 1 and vals[0][0] == 'constant'
              and vals[0][2] == "12'h380"
              and vals[0][3] == 'param_assign'
              and vals[0][4] == 'ref_typespec(work@m)->logic_typespec@3:54-3:59')
        print('SELFCHECK rows=%d -> %s' % (len(r), vals[0] if vals else None))
        print('SELFCHECK: %s (the vpiParent of the ARGUMENT must be read as '
              'param_assign and NOT confused with the enclosing call; the '
              'ref_typespec introduced by |vpiTypespec: must be FOUND and its '
              'own |vpiActual: read one level deeper; the constant stub '
              'printed inside that ref_typespec must not become a second row)'
              % ('PASS' if ok else 'FAIL'))
        sys.exit(0 if ok else 1)

    g = rows(sys.argv[1])
    o = rows(sys.argv[2])
    only = None
    if '--only' in sys.argv:
        only = set(sys.argv[sys.argv.index('--only') + 1].split(','))
    keys = sorted(set(g) | set(o),
                  key=lambda k: (int(k[0].split(':')[0]),
                                 int(k[0].split(':')[1])))
    print('%-11s %-13s %-11s | %-46s | %s' %
          ('arg@', 'call', 'callkind', 'GOLDEN', 'OURS'))
    for k in keys:
        if only and k[0].split(':')[0] not in only:
            continue
        gv, ov = g.get(k), o.get(k)

        def fmt(v):
            if v is None:
                return '<ABSENT>'
            return '%s %s %s p=%s ts=%s' % (v[0], v[1], v[2] or v[5], v[3],
                                            v[4])
        mark = '' if gv == ov else '   <== DIFF'
        print('%-11s %-13s %-11s | %-46s | %s%s' %
              (k[0], k[2][:13], k[1], fmt(gv), fmt(ov), mark))


if __name__ == '__main__':
    main()
