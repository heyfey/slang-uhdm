#!/usr/bin/env python3
"""r10rgg7/census7.py -- the per-instance shape census of rggen_or_reducer.

For every module_inst whose vpiDefName is the reducer definition (in BOTH the
DEF listing `uhdmallModules` and the ELAB `uhdmtopModules`), print
  * the g_reduce arm shape  (MODINST=<n> / ALWAYS=<n> / NOGENSCOPE)
  * every param_assign's Rhs kind and, for a constant, size/decompile
  * next_data's typespec range shape (operation vs constant bounds)
  * the always_comb (the else arm) assignment shape
Keys are (view, instance path); no fullname/span is compared, only shapes and
the value fields the brief names.

  usage: census7.py <dump> [<label>]
GUARD: a view with ZERO reducer instances prints a COUNT line of 0 and exits 3,
so an instrument that reaches nothing can never read as agreement.
"""
import sys, re
sys.path.insert(0, __file__.rsplit('/', 1)[0])
import dumptree as D

SKIP = {'|vpiParent:'}


def rhs_desc(n):
    if n is None:
        return 'NONE'
    if n.kind == 'constant':
        return 'constant(sz=%s,ct=%s,dec=%s)' % (
            n.fields.get('|vpiSize:', '?'), n.fields.get('|vpiConstType:', '?'),
            (n.fields.get('|vpiDecompile:', '?') or '?')[:24])
    if n.kind == 'func_call':
        args = [k for l, k in n.kids if l == '|vpiTfCall:' or l is None]
        return 'func_call(%s)@%s' % (n.fields.get('|vpiName:', '?'), n.loc)
    if n.kind == 'operation':
        return 'operation(op=%s)' % n.fields.get('|vpiOpType:', '?')
    return '%s' % n.kind


def one_child(n, label):
    k = n.kids_of(label, SKIP)
    return k[0] if k else None


def describe(inst, view, out):
    path = inst.name
    # ---- parameters / param_assigns
    pa = []
    for a in inst.kids_of('|vpiParamAssign:', SKIP):
        lhs = one_child(a, '|vpiLhs:')
        rhs = one_child(a, '|vpiRhs:')
        nm = (lhs.name.split('.')[-1] if lhs else '?')
        ovr = a.fields.get('|vpiOverriden:', '0')
        pa.append('%s=%s%s' % (nm, rhs_desc(rhs), '[ovr]' if ovr == '1' else ''))
    # ---- next_data
    nd = []
    for v in inst.kids_of('|vpiVariables:', SKIP):
        ts = one_child(v, '|vpiTypespec:')
        act = one_child(ts, '|vpiActual:') if ts else None
        rng = []
        if act:
            for rr in act.kids_of('|vpiRanges:', SKIP):
                lo = one_child(rr, '|vpiLeftRange:')
                hi = one_child(rr, '|vpiRightRange:')
                rng.append('[%s:%s]' % (rhs_desc(lo), rhs_desc(hi)))
        nd.append('%s:%s%s' % (v.fields.get('|vpiName:', '?'),
                               act.kind if act else 'NOTS', ''.join(rng)))
    # ---- g_reduce arm
    arms = []
    for gsa in inst.kids_of('|vpiGenScopeArray:', SKIP):
        for gs in gsa.kids_of('|vpiGen_scopes:', SKIP) or [k for l, k in gsa.kids
                                                           if l not in SKIP and k.kind == 'gen_scope']:
            mods = [n for n in D.walk(gs, SKIP) if n.kind == 'module_inst']
            alws = [n for n in D.walk(gs, SKIP) if n.kind == 'always']
            asg = []
            for a in alws:
                for x in D.walk(a, SKIP):
                    if x.kind == 'assignment':
                        lhs = one_child(x, '|vpiLhs:')
                        rhs = one_child(x, '|vpiRhs:')
                        idx = one_child(rhs, '|vpiIndex:') if rhs else None
                        asg.append('%s(%s) <= %s(%s)%s' % (
                            lhs.kind if lhs else '?',
                            (lhs.name.split('.')[-1] if lhs else '?'),
                            rhs.kind if rhs else '?',
                            (rhs.name.split('.')[-1] if rhs else '?'),
                            ' idx=' + rhs_desc(idx) if idx else ''))
            arms.append('name=%s MODINST=%d ALWAYS=%d %s' % (
                gsa.fields.get('|vpiName:', gs.name.split('.')[-1]),
                len(mods), len(alws), ';'.join(asg)))
    if not arms:
        arms = ['NOGENSCOPE']
    # ---- the always_comb (the for loop) at instance level
    procs = []
    for p in inst.kids_of('|vpiProcess:', SKIP):
        bounds = [rhs_desc(x) for x in D.walk(p, SKIP)
                  if x.kind == 'operation' and x.fields.get('|vpiOpType:') == '18']
        procs.append('always(t=%s) forstop_ops=%d' % (
            p.fields.get('|vpiAlwaysType:', '?'), len(bounds)))
    out.append('%s\t%s\tPA[%s]\tVAR[%s]\tARM[%s]\tPROC[%s]' %
               (view, path, ' '.join(pa), ' '.join(nd), ' | '.join(arms),
                ' '.join(procs)))


def main():
    dump = sys.argv[1]
    r = D.parse(dump)
    d = [n for l, n in r.kids if n.kind == 'design'][0]
    out = []
    total = 0
    for view, lab in (('DEF', '|uhdmallModules:'), ('ELAB', '|uhdmtopModules:')):
        roots = [n for l, n in d.kids if l == lab]
        insts = []
        for t in roots:
            for n in D.walk(t, SKIP):
                if n.kind == 'module_inst' and n.defname() == 'work@rggen_or_reducer':
                    insts.append(n)
        print('# %s reducer module_inst count = %d' % (view, len(insts)))
        total += len(insts)
        for i in sorted(insts, key=lambda x: x.name):
            describe(i, view, out)
    for l in out:
        print(l)
    if total == 0:
        sys.exit(3)


main()
