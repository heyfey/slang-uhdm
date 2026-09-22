#!/usr/bin/env python3
"""r11u92 SHAPE LISTER — the ORDERED per-holder `vpiNet` and `vpiContAssign`
listings of a uhdm-dump, printed side by side for two dumps.

Built on r11u90's `cacell90.py` parser (the same indent tree), with ONE fix
this pass needs: `program` is a HOLDER.  r11u90's `cacell90.py::walk` promoted
only `module_inst` / `interface_inst` / `gen_scope`, so a cell inside a
program was attributed to the enclosing MODULE and a program-home cell could
not be scored at all; `lister90v.py` matched `program_inst`, a kind the dumper
never prints.  Both are corrected here, and the fixed scorer is
`cacell92.py` (same fix, same file otherwise).

The ORDER of the entries is the payload — LAW B is an ORDER and an ANCHOR —
so entries are printed as a LIST, never a set, and an entry the parser cannot
resolve is printed UNSCORED rather than dropped.

  usage: lister92.py <gold.dump> [<ours.dump>]
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cacell92 import parse, HOLDERS


def walk(node, owner, out):
    me = owner
    if node.kind in HOLDERS:
        me = node.fields.get('vpiFullName', node.name) or node.name
        out.setdefault(me, {'vpiNet': [], 'vpiContAssign': []})
    for fname, kids in node.objs.items():
        if fname == 'vpiParent':
            continue
        for k in kids:
            if fname in ('vpiNet', 'vpiContAssign') and me in out:
                nm = k.fields.get('vpiName', '') or (k.name.rsplit('.', 1)[-1]
                                                     if k.name else '')
                out[me][fname].append('%s|%s|%s' % (k.kind, nm, k.span or '?'))
            walk(k, me, out)
    return out


def listing(path):
    return walk(parse(path), '', {})


def main():
    G = listing(sys.argv[1])
    O = listing(sys.argv[2]) if len(sys.argv) > 2 else None
    for h in sorted(set(G) | set(O or {})):
        for fld in ('vpiNet', 'vpiContAssign'):
            g = G.get(h, {}).get(fld, [])
            o = O.get(h, {}).get(fld, []) if O is not None else None
            tag = '    ' if (o is None or g == o) else 'DIFF'
            print('%s %-28s %-14s gold=%s' % (tag, h, fld, g))
            if o is not None:
                print('     %-28s %-14s ours=%s' % ('', '', o))


if __name__ == '__main__':
    main()
