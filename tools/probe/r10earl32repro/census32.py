#!/usr/bin/env python3
"""r10earl32 — THE CALL-ARGUMENT POLICY CENSUS.

ONE question per subroutine-call ARGUMENT: what OBJECT KIND does each side put
there?  The pass's law is a fold-vs-ref law, so the census cross-tabs

    (CALL KIND, argument object kind)

over a whole design, and then JOINS the two sides argument-for-argument so a
`ref_obj` on one side and a `constant` on the other is named as a DISAGREEMENT
rather than inferred from two independent totals.

THE JOIN KEY IS THE ARGUMENT'S **START** SPAN, never its whole span: the entire
point of this pass's witness is that golden spans `365:75-365:87` (the whole
`dm::DataAddr`) where we span `365:75-365:79` (the `dm::` qualifier alone).
Keying on the whole span would report every mover as "golden-only + ours-only".

Parsing traps encoded (carried from r10earl31/tsread.py, both paid for):
  * an object introduced by a field line sits at the SAME indent as its owner's
    other field lines; its own fields are two columns deeper;
  * `|vpiParent:` / `|vpiFunction:` / already-visited `|vpiActual:` print a
    STUB (type + span, no children).  A stub is never descended into and never
    counted as a call.

usage:  census32.py GOLDEN.dump OURS.dump [--pairs KIND] [--disagree]
        census32.py --selfcheck
LHS IS ALWAYS GOLDEN.
"""
import re
import sys
from collections import Counter, defaultdict

OBJ = re.compile(r'^(\s*)\\_([A-Za-z_0-9]+): (.*)$')
FLD = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')
LOC = re.compile(r'line:(\d+):(\d+)(?:, endln:(\d+):(\d+))?')

CALLS = ('func_call', 'task_call', 'method_func_call', 'method_task_call',
         'sys_func_call', 'sys_task_call')
# fields that introduce a BACK-REFERENCE stub rather than a fresh object
STUBF = ('vpiParent', 'vpiFunction', 'vpiTask')


class Node:
    __slots__ = ('type', 'field', 'sspan', 'span', 'name', 'kids', 'stub',
                 'fields')

    def __init__(self, typ, field, raw):
        self.type = typ
        self.field = field
        m = LOC.search(raw)
        if m:
            self.sspan = '%s:%s' % (m.group(1), m.group(2))
            self.span = self.sspan + '-' + ('%s:%s' % (m.group(3), m.group(4))
                                            if m.group(3) else '?')
        else:
            self.sspan = '?'
            self.span = '?'
        mn = re.match(r'^\(([^)]*)\)', raw.strip())
        self.name = mn.group(1) if mn else ''
        self.kids = []
        self.stub = field in STUBF
        self.fields = {}


def parse(path):
    """-> list of NON-STUB call nodes, each with its vpiArgument kids wired."""
    root = Node('DESIGN', '', '')
    stack = [(-2, root)]
    cur_field = {}
    calls = []
    with open(path, 'rt', errors='replace') as f:
        for line in f:
            line = line.rstrip('\n')
            m = OBJ.match(line)
            if m:
                ind = len(m.group(1))
                while stack and stack[-1][0] >= ind:
                    stack.pop()
                parent = stack[-1][1] if stack else root
                n = Node(m.group(2), cur_field.get(id(parent), ''), m.group(3))
                parent.kids.append(n)
                if n.type in CALLS and not n.stub:
                    calls.append(n)
                stack.append((ind, n))
                continue
            m = FLD.match(line)
            if m:
                ind = len(m.group(1))
                while stack and stack[-1][0] >= ind:
                    stack.pop()
                owner = stack[-1][1] if stack else root
                cur_field[id(owner)] = m.group(2)
                if m.group(2) in ('vpiName', 'vpiDecompile', 'vpiFullName'):
                    owner.fields[m.group(2)] = m.group(3)
    return calls


def args_of(call):
    return [k for k in call.kids if k.field == 'vpiArgument']


def key_of(call, arg):
    """(call kind, call name, call start span, argument start span)."""
    return (call.type, call.name or call.fields.get('vpiName', ''),
            call.sspan, arg.sspan)


def collect(path):
    """-> {key: argument-kind}, plus a Counter of duplicate keys."""
    out = {}
    dup = Counter()
    for c in parse(path):
        for a in args_of(c):
            k = key_of(c, a)
            if k in out:
                dup[k] += 1
                # keep the FIRST; a design listing that prints the same call
                # twice prints it identically, so this only ever hides a true
                # duplicate, and the count is reported.
                continue
            out[k] = a.type
    return out, dup


def main():
    if '--selfcheck' in sys.argv:
        import tempfile
        import os
        txt = (
            "\\_module_inst: work@m (work@m), line:1:1, endln:9:10\n"
            "  |vpiRhs:\n"
            "  \\_func_call: (f), line:5:10, endln:5:20\n"
            "    |vpiParent:\n"
            "    \\_cont_assign: , line:5:3, endln:5:20\n"
            "    |vpiArgument:\n"
            "    \\_constant: , line:5:12, endln:5:18\n"
            "      |vpiParent:\n"
            "      \\_func_call: (f), line:5:10, endln:5:20\n"
            "      |vpiDecompile:8'h5\n"
            "    |vpiArgument:\n"
            "    \\_ref_obj: (work@m.s), line:5:20, endln:5:21\n"
            "    |vpiName:f\n"
            "    |vpiFunction:\n"
            "    \\_function: (work@m.f), line:2:3, endln:3:14\n")
        fd, p = tempfile.mkstemp(suffix='.dump')
        os.write(fd, txt.encode())
        os.close(fd)
        cs = parse(p)
        os.unlink(p)
        ok = True
        # exactly ONE call: the vpiParent stub inside the argument must NOT be
        # counted, and neither must the vpiFunction stub.
        if len(cs) != 1:
            ok = False
        else:
            a = args_of(cs[0])
            if [x.type for x in a] != ['constant', 'ref_obj']:
                ok = False
        print('SELFCHECK calls=%d args=%s' %
              (len(cs), [x.type for x in args_of(cs[0])] if cs else None))
        print('SELFCHECK: %s (the vpiParent stub of a call printed INSIDE its '
              'own argument must not be counted as a second call, and the '
              'vpiFunction stub must not be counted as an argument)'
              % ('PASS' if ok else 'FAIL'))
        sys.exit(0 if ok else 1)

    g, gdup = collect(sys.argv[1])
    o, odup = collect(sys.argv[2])
    print('golden call-args %d (dup keys %d)   ours %d (dup keys %d)'
          % (len(g), sum(gdup.values()), len(o), sum(odup.values())))

    tab = defaultdict(Counter)
    for k, v in g.items():
        tab[k[0]]['g:' + v] += 1
    for k, v in o.items():
        tab[k[0]]['o:' + v] += 1
    joint = defaultdict(Counter)
    for k, v in g.items():
        if k in o:
            joint[k[0]][(v, o[k])] += 1
    print('\n== per CALL KIND: argument object kinds, each side ==')
    for ck in sorted(tab):
        gs = sorted([(c, n) for c, n in tab[ck].items() if c.startswith('g:')])
        os_ = sorted([(c, n) for c, n in tab[ck].items() if c.startswith('o:')])
        print('  %-18s golden %s' % (ck, ' '.join('%s=%d' % (c[2:], n)
                                                  for c, n in gs)))
        print('  %-18s ours   %s' % ('', ' '.join('%s=%d' % (c[2:], n)
                                                  for c, n in os_)))
    print('\n== JOINED argument-for-argument (start-span key) ==')
    tot_dis = 0
    for ck in sorted(joint):
        for (gv, ov), n in sorted(joint[ck].items(), key=lambda kv: -kv[1]):
            mark = '' if gv == ov else '   <== DISAGREE'
            if gv != ov:
                tot_dis += n
            print('  %-18s golden=%-14s ours=%-14s %6d%s'
                  % (ck, gv, ov, n, mark))
    gonly = [k for k in g if k not in o]
    oonly = [k for k in o if k not in g]
    print('\n  joined disagreements: %d ; golden-only arg slots %d ; '
          'ours-only arg slots %d' % (tot_dis, len(gonly), len(oonly)))

    if '--disagree' in sys.argv:
        print('\n== every DISAGREEING slot ==')
        for k in sorted(g):
            if k in o and g[k] != o[k]:
                print('  %-16s %-24s call@%-12s arg@%-12s golden=%-12s ours=%s'
                      % (k[0], k[1][:24], k[2], k[3], g[k], o[k]))
    if '--gonly' in sys.argv:
        print('\n== golden-only arg slots (first 40) ==')
        for k in sorted(gonly)[:40]:
            print('  %-16s %-24s call@%-12s arg@%-12s %s'
                  % (k[0], k[1][:24], k[2], k[3], g[k]))
        print('\n== ours-only arg slots (first 40) ==')
        for k in sorted(oonly)[:40]:
            print('  %-16s %-24s call@%-12s arg@%-12s %s'
                  % (k[0], k[1][:24], k[2], k[3], o[k]))


if __name__ == '__main__':
    main()
