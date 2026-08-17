#!/usr/bin/env python3
"""r10rgg7/armscan.py -- WHICH ARM did this database elaborate?

For every module_inst of the grid's `sub` definition, in BOTH views, print
    <view> <instpath> N=<n> ARM=<A|B|BOTH|NONE> NEXT=<rhs shape> GS=<n>
where ARM=A means the `if` arm (its `a_mark`/`u_sub`/`gl` content is present)
and ARM=B the `else` arm (`b_mark`).

  usage: armscan.py <dump>
GUARDS:
  * a dump with ZERO `sub` instances prints `INSTS=0` and exits 3 -- an
    instrument that reaches nothing must never read as agreement.
  * the arm is decided by CONTENT, never by the gen_scope's NAME: both arms of
    every cell are named g_reduce, exactly as rggen_or_reducer names them.
  * only CONTAINMENT edges are walked (vpiParent is skipped), so a back
    reference can never manufacture an arm.
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import dumptree as D

SKIP = {'|vpiParent:'}


def rhs_desc(n):
    if n is None:
        return 'NONE'
    if n.kind == 'constant':
        return 'const(%s,ct=%s,dec=%s)' % (n.fields.get('|vpiSize:', '?'),
                                           n.fields.get('|vpiConstType:', '?'),
                                           (n.fields.get('|vpiDecompile:', '?') or '?')[:16])
    if n.kind == 'func_call':
        return 'call(%s)' % n.fields.get('|vpiName:', '?')
    if n.kind == 'operation':
        return 'oper(%s)' % n.fields.get('|vpiOpType:', '?')
    return n.kind


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
                dn = n.defname()
                if not dn.endswith('@sub'):
                    continue
                total += 1
                # N and NEXT from the param_assigns
                nval, nextd = '?', 'NOPA'
                for a in n.kids_of('|vpiParamAssign:', SKIP):
                    lhs = a.kids_of('|vpiLhs:', SKIP)
                    rhs = a.kids_of('|vpiRhs:', SKIP)
                    if not lhs:
                        continue
                    nm = lhs[0].name.split('.')[-1]
                    if nm == 'N':
                        nval = rhs_desc(rhs[0]) if rhs else 'NONE'
                    elif nm == 'NEXT':
                        nextd = rhs_desc(rhs[0]) if rhs else 'NONE'
                gsas = n.kids_of('|vpiGenScopeArray:', SKIP)
                names = set()
                for gsa in gsas:
                    for x in D.walk(gsa, SKIP):
                        v = x.fields.get('|vpiName:', '')
                        if v in ('a_mark', 'b_mark'):
                            names.add(v)
                        if x.kind == 'module_inst' and \
                           x.defname().endswith('@leaf'):
                            names.add('a_mark')  # ARM_INST's if-arm content
                arm = ('BOTH' if {'a_mark', 'b_mark'} <= names else
                       'A' if 'a_mark' in names else
                       'B' if 'b_mark' in names else 'NONE')
                rows.append('%s\t%s\tN=%s\tARM=%s\tNEXT=%s\tGSA=%d' %
                            (view, n.name, nval, arm, nextd, len(gsas)))
    print('INSTS=%d' % total)
    for x in sorted(rows):
        print(x)
    if total == 0:
        sys.exit(3)


main()
