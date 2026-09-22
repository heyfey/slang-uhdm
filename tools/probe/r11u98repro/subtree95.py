#!/usr/bin/env python3
"""r11u95 SUBTREE ARBITER — the ORDERED per-holder `vpiProcess`, `vpiTaskFunc`
and `vpiClassDefn` listings, scored entry by entry.

WHY IT EXISTS: `cacell95.py` (= r11u92's `cacell92.py`) scores `cont_assign`
CELLS and nothing else — the r11u93 verifier said so in as many words when it
found that the per-cell arbiters were BLIND to the processes and subroutines
r11u92's R0 named.  This pass moves exactly those three vectors, so it carries
an instrument the cell scorer cannot see.

Each entry is keyed by (object kind, name, span) AND by the two fields the
generated `Compare`s read on these objects that a name+span key would miss:
`vpiInstance`'s fullname (the § caProgTaskFuncInstIsElab95 face is ONLY that
field) and, for a process, its statement's `vpiFullName` (the block name).
The ORDER is the payload for LAW A, so entries are a LIST, never a set, and a
holder whose lists differ only in order is reported as ORDER-DIFF.

  usage: subtree95.py <gold.dump> <ours.dump> [--rows]
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cacell95 import parse, HOLDERS

FIELDS = ('vpiProcess', 'vpiTaskFunc', 'vpiClassDefn')


def entry(k):
    nm = k.fields.get('vpiName', '') or (k.name.rsplit('.', 1)[-1]
                                         if k.name else '')
    # An instance header prints as `\\_program: work@prg (work@dut.u_p), ...`
    # — the parenthesised part is NOT the first token, so the shared parser
    # leaves `name` empty on it.  The SPAN separates the two views (a def
    # program spans its declaration, an elab program spans the instantiation),
    # which is exactly what § caProgTaskFuncInstIsElab95 turns on, so the key
    # carries both.
    inst = ''
    for kid in k.objs.get('vpiInstance', []):
        inst = '%s@%s' % (kid.fields.get('vpiFullName', '') or kid.name or
                          kid.kind, kid.span or '?')
    blk = ''
    for kid in k.objs.get('vpiStmt', []):
        blk = kid.fields.get('vpiFullName', '') or kid.name or ''
    return '%s|%s|%s|inst=%s|stmt=%s' % (k.kind, nm, k.span or '?', inst, blk)


def walk(node, owner, out):
    me = owner
    if node.kind in HOLDERS:
        me = node.fields.get('vpiFullName', node.name) or node.name
        out.setdefault(me, {f: [] for f in FIELDS})
    for fname, kids in node.objs.items():
        if fname == 'vpiParent':
            continue
        for k in kids:
            if fname in FIELDS and me in out:
                out[me][fname].append(entry(k))
            walk(k, me, out)
    return out


def listing(path):
    return walk(parse(path), '', {})


def main():
    G = listing(sys.argv[1])
    O = listing(sys.argv[2])
    rows = '--rows' in sys.argv[3:]
    tot = dict(MATCH=0, DIFF=0, GOLD=0, OURS=0, ORDER=0)
    for h in sorted(set(G) | set(O)):
        for fld in FIELDS:
            g = G.get(h, {}).get(fld, [])
            o = O.get(h, {}).get(fld, [])
            if not g and not o:
                continue
            gs, os_ = sorted(g), sorted(o)
            inter = list(gs)
            for x in os_:
                if x in inter:
                    inter.remove(x)
            gonly = inter
            inter2 = list(os_)
            for x in gs:
                if x in inter2:
                    inter2.remove(x)
            oonly = inter2
            m = len(gs) - len(gonly)
            tot['MATCH'] += m
            tot['GOLD'] += len(gonly)
            tot['OURS'] += len(oonly)
            order = 1 if (not gonly and not oonly and g != o) else 0
            tot['ORDER'] += order
            if rows and (gonly or oonly or order):
                print('%-32s %-14s' % (h, fld))
                print('    gold=%s' % g)
                print('    ours=%s' % o)
    print('SUBTREE MATCH=%d GOLD-ONLY=%d OURS-ONLY=%d ORDER-DIFF=%d'
          % (tot['MATCH'], tot['GOLD'], tot['OURS'], tot['ORDER']))


if __name__ == '__main__':
    main()
