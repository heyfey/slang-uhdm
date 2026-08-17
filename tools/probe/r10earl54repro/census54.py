#!/usr/bin/env python3
"""r10earl54 CENSUS — the whole-design population of § connReplFoldNested54,
counted from the GOLDEN and PRISTINE dumps ALONE.

Run it BEFORE the patched binary exists.  It answers three numbers that the
patched database is then held to:

  MOVERS      multiconcat operations we emit inside an ELABORATED port-connection
              actual, at depth > 0, where GOLDEN has a `constant` at the same
              span in the same (instance, port) slot.  These are exactly what
              the law must turn, and nothing else may move.
  KEEP        the same, but where GOLDEN also has a multiconcat.  These must NOT
              move.  A patched run that folds any of these is an OVER-FIRE.
  UNPAIRED    ours has a multiconcat in a slot golden's dump does not offer at
              all (golden folded a WIDER expression, or the contexts differ).
              Abstain territory; reported so it is never silently counted as
              either.

  usage: census54.py <golden.dump> <ours.dump>
         census54.py --selftest <a1-workdir>     # the a1 grid's known answers

METHOD NOTES (each one a trap this campaign has paid for)
  * BACK-REFERENCES ARE NOT CHILDREN.  uhdm-dump prints `|vpiParent:` and
    `|vpiActual:` values as `\\_kind:` lines at the SAME indentation as real
    child fields, so an indentation-only walker pushes an object's own PARENT
    onto its ancestor stack.  The first version of this file did exactly that
    and reported 0 multiconcats on a grid that provably has nine.  Every object
    line is therefore attributed to the LAST `|<field>:` label at its
    indentation, and `vpiParent` / `vpiActual` subtrees are skipped whole.
  * DEPTH > 0 ONLY.  A replication that IS the whole actual is already folded by
    the pre-existing arm; counting it would inflate MOVERS by objects that
    cannot move.
  * THE DEF LISTING IS EXCLUDED, twice over: any chain through a `ref_module`,
    and the whole `uhdmallModules` subtree.  Golden keeps op34 in the def view
    (measured, a1 grid) and so do we.
  * The key is (instance-full-path, port-name, line:col-endline:endcol).  Our
    dump prints NO FILE on non-top objects, so a bare span key collides across
    files; the instance path disambiguates.
  * `vpiOpType` is read only at the operation's own indentation + 2, because the
    inline parent print puts the CHILD's opType text between the operation
    header and its own.
"""
import re
import sys
from collections import Counter

OBJ = re.compile(r'^(\s*)\\_([a-z_0-9]+):(.*)$')
FIELD = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')
LOC = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')
INST = re.compile(r'^\s*\\_module_inst: \S+ \(([^)]*)\)')
PORT = re.compile(r'^\s*\\_port: \(([^)]*)\)')

BACKREF = {'vpiParent', 'vpiActual'}
# Expression-shaped kinds that add a nesting LEVEL inside a HighConn actual.
NESTERS = ('operation', 'constant', 'hier_path', 'part_select', 'bit_select',
           'ref_obj', 'indexed_part_select', 'var_select', 'func_call',
           'sys_func_call', 'ref_typespec')


def span(rest):
    m = LOC.search(rest)
    return '%s:%s-%s:%s' % m.groups() if m else '?'


def scan(path):
    """{key: 'constant' | 'multiconcat' | 'operation'} for every expression
    object inside an ELABORATED port HighConn at nesting depth > 0."""
    out = {}
    stack = []            # (indent, kind, name)  -- real children only
    label = {}            # indent -> last '|<field>:' label seen there
    pendOp = {}           # indent -> key of an operation awaiting its vpiOpType
    skipInd = None        # inside a back-reference subtree: skip while deeper
    with open(path, 'rt', errors='replace') as f:
        for raw in f:
            line = raw.rstrip('\n')
            if not line.strip():
                continue
            fm = FIELD.match(line)
            if fm:
                ind = len(fm.group(1))
                if skipInd is not None and ind > skipInd:
                    continue
                skipInd = None
                label[ind] = fm.group(2)
                if fm.group(2) == 'vpiOpType' and (ind - 2) in pendOp:
                    key = pendOp.pop(ind - 2)
                    out[key] = ('multiconcat' if fm.group(3) == '34'
                                else 'operation')
                continue
            om = OBJ.match(line)
            if om is None:
                continue
            ind, kind, rest = len(om.group(1)), om.group(2), om.group(3)
            if skipInd is not None and ind > skipInd:
                continue
            skipInd = None
            if label.get(ind) in BACKREF:
                # A vpiParent / vpiActual print: not a child.  Skip its whole
                # (usually one-line) subtree.
                skipInd = ind
                continue
            while stack and stack[-1][0] >= ind:
                stack.pop()
            name = None
            if kind == 'module_inst':
                mm = INST.match(line)
                name = mm.group(1) if mm else '?'
            elif kind == 'port':
                mm = PORT.match(line)
                name = mm.group(1) if mm else '?'
            stack.append((ind, kind, name))
            # DEF listing?  `uhdmallModules` is the top label of the def view.
            if label.get(0) == 'uhdmallModules':
                continue
            inst = port = None
            depth = 0
            bad = False
            for _i, k, nm in stack[:-1]:
                if k == 'ref_module':
                    bad = True
                if k == 'module_inst':
                    inst, port, depth = nm, None, 0
                elif k == 'port':
                    port, depth = nm, 0
                elif port is not None and k in NESTERS:
                    depth += 1
            if bad or inst is None or port is None or depth < 1:
                continue
            key = '%s|%s|%s' % (inst, port, span(rest))
            if kind == 'constant':
                out[key] = 'constant'
            elif kind == 'operation':
                pendOp[ind] = key
    return out


def report(g, o):
    print('GOLDEN slots=%d  OURS slots=%d' % (len(g), len(o)))
    movers, keep, unpaired = [], [], []
    for k, v in o.items():
        if v != 'multiconcat':
            continue
        gv = g.get(k)
        if gv is None:
            unpaired.append(k)
        elif gv == 'constant':
            movers.append(k)
        else:
            keep.append(k)
    print('MOVERS   (ours multiconcat -> golden constant) = %d' % len(movers))
    print('KEEP     (ours multiconcat, golden op too)     = %d' % len(keep))
    print('UNPAIRED (no golden slot at that key)          = %d' % len(unpaired))
    for tag, lst in (('MOVERS', movers), ('KEEP', keep), ('UNPAIRED', unpaired)):
        if not lst:
            continue
        print('-- %s by span' % tag)
        for k, n in Counter(x.split('|')[2] for x in lst).most_common(20):
            print('   %-24s %d' % (k, n))
    if movers:
        print('-- MOVERS: first 12 full keys')
        for k in sorted(movers)[:12]:
            print('   %s' % k)
    return movers, keep, unpaired


def main():
    if len(sys.argv) == 3 and sys.argv[1] == '--selftest':
        wd = sys.argv[2]
        g, o = scan(wd + '/g.dump'), scan(wd + '/o.dump')
        m, k, u = report(g, o)
        gg = scan(wd + '/g.dump')
        mm, kk, uu = report(gg, gg)
        # GOLDEN-VS-GOLDEN IS NOT ALL ZEROS, AND THAT IS THE POINT.  KEEP counts
        # multiconcats golden ITSELF keeps (a1 `u_nonc`, non-constant body), so
        # golden compared with golden must report KEEP=1 — the census's own
        # statement that this cell must not move.  Only MOVERS and UNPAIRED are
        # required to vanish; an earlier expectation of 0/0/0 here was the
        # instrument being wrong about its own output.
        ok = (len(m) == 4 and len(k) == 1 and len(u) == 4
              and (len(mm), len(kk), len(uu)) == (0, 1, 0))
        print('SELFTEST %s  (want MOVERS=4 KEEP=1 UNPAIRED=4, '
              'g-vs-g MOVERS=0 KEEP=1 UNPAIRED=0)'
              % ('PASS' if ok else 'FAIL'))
        return 0 if ok else 1
    if len(sys.argv) != 3:
        print(__doc__)
        return 2
    report(scan(sys.argv[1]), scan(sys.argv[2]))
    return 0


if __name__ == '__main__':
    sys.exit(main())
