#!/usr/bin/env python3
"""r10oth8 -- WHICH array_vars disagree on the NESTED element's `vpiSigned`.

    usage: ct8nested.py <g.dump> <o.dump>

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

WHY THIS EXISTS.  `ct8census.sh` reports the nested-element `vpiSigned` count as
a single number per side, and on SeqDriver that number moved from 25 to 12
against a golden of 23 -- i.e. TOWARDS golden on two corpora and AWAY on a third
if the number is read as one population.  It is not one population: golden puts
`vpiSigned` on the ELEMENT at SUBROUTINE-LOCAL scope and on the ARRAY at
class/module scope, so a single count mixes two opposite laws.  This script
splits it by the object's own fullname -- a name containing a `.` after the
class/module qualifier is a subroutine or block local -- and prints the
disagreeing objects BY NAME so the two populations can never be conflated again.
A dump that yields no array_var at all prints UNMEASURED.
"""
import sys

sys.path.insert(0, __file__.rsplit('/', 1)[0])
from ct8fields import objects, own_and_nested  # noqa: E402


def side(dump):
    """name -> (own-vpiSigned, nested-vpiSigned) for the DEFINITIONAL occurrence.

    THE KEY IS THE OBJECT NAME IN PARENTHESES, taken from the header and
    stripped of the dump's indentation.  The first draft keyed on
    `hdr.split(', ')[0]` -- which keeps the leading spaces, so the SAME object
    at two dump depths produced two keys and EVERY row read `ONE-SIDE-ONLY`.
    That is the campaign's objects-vs-dump-lines trap wearing a third hat, and
    it is why this docstring exists.
    """
    lines = open(dump, encoding='utf-8', errors='replace').readlines()
    best = {}
    for i, ind, hdr in objects(lines, 'array_var', ''):
        own, refs, nested = own_and_nested(lines, i, ind)
        h = hdr.strip()
        key = h[h.find('(') + 1:h.find(')')] if '(' in h else h
        score = len(own) + len(refs)
        if key in best and best[key][0] >= score:
            continue
        d = dict(own)
        best[key] = (score, 'vpiSigned' in d,
                     any(fn == 'vpiSigned' for _o, fn, _v in nested))
    return {k: (v[1], v[2]) for k, v in best.items()}


def kind(name):
    """SUBROUTINE/BLOCK local vs class-property / module-variable, by NAME.

    Surelog spells a package class's property `pkg::cls::prop` (two `::`) and a
    method LOCAL `pkg::cls::method::local` (three), a $unit class property
    `work@cls::prop` (one), and a module variable `work@mod.var` versus a
    subroutine local `work@mod.func.local` (an extra `.`).  So: three or more
    `::` segments, or more than one `.` after the `@`, is a LOCAL.
    """
    tail = name.split('@', 1)[-1]
    if tail.count('::') >= 3:
        return 'local'
    if tail.count('::') == 0:
        return 'local' if tail.count('.') > 1 else 'member'
    # one or two `::`: a $unit class property, a package class property, or a
    # module/instance-qualified name with a subroutine segment.
    return 'local' if '.' in tail.split('::')[-2] else 'member'


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    G, O = side(sys.argv[1]), side(sys.argv[2])
    if not G or not O:
        print('UNMEASURED: one dump yielded no array_var at all')
        return 3
    rows = []
    for n in sorted(set(G) | set(O)):
        g = G.get(n)
        o = O.get(n)
        if g is None or o is None:
            rows.append((kind(n), n, 'ONE-SIDE-ONLY',
                         'golden' if o is None else 'ours'))
            continue
        if g[1] != o[1]:
            rows.append((kind(n), n, 'nested golden=%s ours=%s' % (g[1], o[1]),
                         ''))
    if not rows:
        print('nested vpiSigned: NO disagreement on any array_var')
        return 0
    for k in ('member', 'local'):
        sel = [r for r in rows if r[0] == k]
        print('== %s objects with a NESTED-vpiSigned disagreement: %d' % (k, len(sel)))
        for _k, n, why, extra in sel[:40]:
            print('   %-64s %s %s' % (n, why, extra))
    return 0


if __name__ == '__main__':
    sys.exit(main())
