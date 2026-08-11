#!/usr/bin/env python3
"""r10uvm52repro/bindiff.py — join golden's and our ref_obj tables and print
EVERY ref_obj whose vpiActual disagrees.  This is the instrument that decides
the call-argument binding predicate, so it carries its own controls.

LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.

JOIN KEY.  NOT the vpiFullName — golden spells a call argument under a hier_path
as `<sub>::<path>::<arg>` where we spell `<sub>::<arg>`, so a fullname join would
report every argument as unpaired and the real disagreement would drown.  The key
is (source loc, LAST name segment, relation, enclosing subroutine name).

GUARDS
  * refuses to report if either side parsed to zero rows;
  * prints the UNPAIRED counts on both sides — a key that pairs nothing must not
    read as "no disagreement";
  * `--selftest` runs a built-in fixture with one agreement, one disagreement
    and one unpaired row on each side, and asserts all four numbers.

Usage: bindiff.py <g.reftab> <o.reftab> [--only-differ] [--filter REGEX]
       bindiff.py --selftest
Row format produced by dumptree.py reftab:
  loc|fullname|relation|subroutine|container-kind|actual-kind
"""
import re
import sys


# CONTAINER PRIORITY — a MEASURED instrument defect, fixed here.  uhdm-dump
# prints the same class body in more than one tree position, and in some of
# them the class_defn's own printing is a vpiParent BACK-EDGE (which the parser
# correctly drops), so the nearest surviving container ancestor is the PACKAGE.
# Keying on (loc,name,rel,sub) alone let the package-labelled copy overwrite the
# class_defn-labelled one, and the resulting grid reported "golden NEVER binds a
# class-method call argument" — which is FALSE.  Keep the most specific
# container.
_CPRI = {'class_defn': 3, 'module_inst': 2, 'package': 1, 'design': 0, '-': -1}


def load(path):
    rows = {}
    with open(path) as f:
        for ln in f:
            ln = ln.rstrip('\n')
            if not ln or ln.startswith('UNMEASURED') or ln.startswith('FATAL'):
                continue
            p = ln.split('|')
            if len(p) < 6:
                continue
            loc, full, rel, sub, cont, act = p[:6]
            ctx = p[6] if len(p) > 6 else '-'
            leaf = full.split('::')[-1].split('.')[-1]
            k = (loc, leaf, rel, sub)
            old = rows.get(k)
            if old is not None:
                # more specific container wins; at equal specificity a BOUND
                # printing wins over an unbound one, so a duplicate printing can
                # never manufacture a false "golden does not bind".
                if (_CPRI.get(cont, -1), act != 'NONE') <= \
                   (_CPRI.get(old[0], -1), old[1] != 'NONE'):
                    continue
            rows[k] = (cont, act, full, ctx)
    return rows


def run(gp, op, only_differ, filt):
    g, o = load(gp), load(op)
    if not g or not o:
        print('FATAL: %d golden rows, %d ours rows — REFUSING TO REPORT'
              % (len(g), len(o)))
        return 5
    rx = re.compile(filt) if filt else None
    both = set(g) & set(o)
    agree = differ = 0
    hist = {}
    lines = []
    for k in sorted(both):
        gc, ga, gf, gx = g[k]
        oc, oa, of, ox = o[k]
        if ga == oa:
            agree += 1
            continue
        differ += 1
        hist[(k[2], gc, ga, oa)] = hist.get((k[2], gc, ga, oa), 0) + 1
        if rx and not rx.search('|'.join(k) + '|' + ga + '|' + oa):
            continue
        lines.append('%-12s %-24s rel=%-14s sub=%-30s LHSgolden=%-11s '
                     'RHSours=%-11s Gctx=%-28s Octx=%s'
                     % (k[0], k[1][:24], k[2], k[3][:30], ga, oa, gx, ox))
    print('PAIRED %d  AGREE %d  DIFFER %d   UNPAIRED golden-only %d  '
          'ours-only %d' % (len(both), agree, differ,
                            len(set(g) - both), len(set(o) - both)))
    print('--- disagreement histogram (relation, container, LHS golden, RHS ours)')
    for k in sorted(hist, key=lambda k: -hist[k]):
        print('  %-14s %-12s LHSgolden=%-12s RHSours=%-12s  x%d'
              % (k[0], k[1], k[2], k[3], hist[k]))
    if not only_differ:
        print('--- rows')
        for l in lines:
            print(l)
    return 0


def ctxcensus(gp, op, rel, cont_want):
    """THE PREDICATE GRID.  For every PAIRED ref_obj in the requested relation
    and container, cross golden's structural CONTEXT (parent kind / grandparent
    kind) with whether each side attached an actual.  This is what separates the
    binds golden KEEPS from the ones it refuses."""
    g, o = load(gp), load(op)
    if not g or not o:
        print('FATAL: %d golden rows, %d ours rows — REFUSING TO REPORT'
              % (len(g), len(o)))
        return 5
    tab = {}
    for k in set(g) & set(o):
        if k[2] != rel:
            continue
        gc, ga, gf, gx = g[k]
        oc, oa, of, ox = o[k]
        if cont_want != '*' and gc != cont_want:
            continue
        key = (gx, ox, 'G:' + ('BOUND' if ga != 'NONE' else 'none'),
               'O:' + ('BOUND' if oa != 'NONE' else 'none'))
        tab[key] = tab.get(key, 0) + 1
    if not tab:
        print('UNMEASURED: no paired rows with rel=%s container=%s'
              % (rel, cont_want))
        return 0
    print('PREDICATE GRID  rel=%s container=%s   (Gctx = golden parent/grandparent,'
          ' Octx = ours)' % (rel, cont_want))
    print('%-30s %-30s %-9s %-9s %s' % ('Gctx', 'Octx', 'GOLDEN', 'OURS', 'N'))
    for k in sorted(tab, key=lambda k: -tab[k]):
        print('%-30s %-30s %-9s %-9s %d' % (k[0], k[1], k[2], k[3], tab[k]))
    return 0


SELF_G = """1:1|p::f::a|vpiArgument|f|package|io_decl|func_call/begin
2:2|p::c::m::b|vpiArgument|m|class_defn|NONE|method_func_call/hier_path
3:3|p::c::m::z|vpiOperand|m|class_defn|io_decl|operation/begin
9:9|p::c::m::gonly|vpiRhs|m|class_defn|io_decl|assignment/begin
4:4|p::c::m::dup|vpiArgument|m|package|io_decl|method_func_call/hier_path
4:4|p::c::m::dup|vpiArgument|m|class_defn|io_decl|method_func_call/hier_path
"""
SELF_O = """1:1|p::f::a|vpiArgument|f|package|io_decl|func_call/begin
2:2|p::c::m::x.y::b|vpiArgument|m|class_defn|io_decl|method_func_call/hier_path
3:3|p::c::m::z|vpiOperand|m|class_defn|io_decl|operation/begin
8:8|p::c::m::oonly|vpiRhs|m|class_defn|io_decl|assignment/begin
4:4|p::c::m::dup|vpiArgument|m|package|io_decl|method_func_call/hier_path
"""


def selftest():
    import tempfile
    import os
    d = tempfile.mkdtemp()
    gp, op = os.path.join(d, 'g'), os.path.join(d, 'o')
    open(gp, 'w').write(SELF_G)
    open(op, 'w').write(SELF_O)
    g, o = load(gp), load(op)
    both = set(g) & set(o)
    assert len(both) == 4, both          # the hier-path fullname MUST still pair
    dif = [k for k in both if g[k][1] != o[k][1]]
    assert len(dif) == 1 and dif[0][1] == 'b', dif
    assert len(set(g) - both) == 1 and len(set(o) - both) == 1
    # THE DUPLICATE-PRINTING CONTROL: the same object printed once under the
    # package and once under the class_defn must be reported as class_defn.
    assert g[('4:4', 'dup', 'vpiArgument', 'm')][0] == 'class_defn', g
    print('SELFTEST OK: 4 paired (incl. the hier-path-fullname argument and the '
          'duplicate printing, which resolves to class_defn), 1 differ '
          '(b: golden NONE / ours io_decl), 1 unpaired each side')


def main():
    a = sys.argv[1:]
    if a[:1] == ['--selftest']:
        selftest()
        return 0
    if len(a) < 2:
        print(__doc__)
        return 2
    filt = None
    if '--filter' in a:
        filt = a[a.index('--filter') + 1]
    if '--ctxcensus' in a:
        i = a.index('--ctxcensus')
        return ctxcensus(a[0], a[1], a[i + 1], a[i + 2])
    return run(a[0], a[1], '--only-differ' in a, filt)


if __name__ == '__main__':
    sys.exit(main())
