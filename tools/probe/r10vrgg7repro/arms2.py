#!/usr/bin/env python3
"""r10vrgg7/arms2.py -- WHICH ARM did this database elaborate, generically.

Unlike r10rgg7's armscan.py this makes NO assumption about the number of arms
or about which content belongs to which arm: it reports, per `sub` module_inst
and per view, the SORTED SET of marker names (`a_mark`/`b_mark`/`c_mark`) that
appear anywhere under that instance's gen_scope_arrays, the gen_scope_array
count, the number of gen_scopes, and the nested `sub`/`leaf` instance counts.

  usage: arms2.py <dump>

GUARDS
  * a dump with ZERO `sub` instances prints INSTS=0 and exits 3 -- an
    instrument that reaches nothing must never read as agreement.
  * ONLY CONTAINMENT edges are walked (vpiParent skipped), so a back reference
    can never manufacture an arm.
  * the arm is decided by CONTENT, never by the gen_scope's NAME: every cell
    names both arms g_reduce.
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import dumptree as D

SKIP = {'|vpiParent:'}
MARKS = ('a_mark', 'b_mark', 'c_mark')


def main():
    r = D.parse(sys.argv[1])
    des = [n for l, n in r.kids if n.kind == 'design']
    if not des:
        print('INSTS=0 NODESIGN')
        sys.exit(3)
    d = des[0]
    rows = []
    total = 0
    for view, lab in (('DEF', '|uhdmallModules:'), ('ELAB', '|uhdmtopModules:')):
        for t in [n for l, n in d.kids if l == lab]:
            for n in D.walk(t, SKIP):
                if n.kind != 'module_inst':
                    continue
                if not n.defname().endswith('@sub'):
                    continue
                total += 1
                gsas = n.kids_of('|vpiGenScopeArray:', SKIP)
                marks, gs, nsub, nleaf = set(), 0, 0, 0
                for gsa in gsas:
                    for x in D.walk(gsa, SKIP):
                        v = x.fields.get('|vpiName:', '')
                        if v in MARKS:
                            marks.add(v)
                        if x.kind == 'gen_scope':
                            gs += 1
                        if x.kind == 'module_inst':
                            if x.defname().endswith('@sub'):
                                nsub += 1
                            elif x.defname().endswith('@leaf'):
                                nleaf += 1
                rows.append('%s\t%s\tMARKS=%s\tGSA=%d\tGS=%d\tSUB=%d\tLEAF=%d'
                            % (view, n.name, ','.join(sorted(marks)) or '-',
                               len(gsas), gs, nsub, nleaf))
    print('INSTS=%d' % total)
    for x in sorted(rows):
        print(x)
    if total == 0:
        sys.exit(3)


main()
