#!/usr/bin/env python3
"""r10uvm225 — the BASE-NET census, the precondition of the array_net law.

Surelog's producer writes the array_net's inner element net as a COPY of the
BASE net's fields:

    logic_net* elem = s.MakeLogic_net();
    elem->VpiName(orig_net->getName());
    elem->VpiNetType(dest_net->VpiNetType());        // UhdmWriter.cpp:923
    elem->VpiParent(anet);
    if (dest_net->Typespec()) { … }                  // :925-930

so `copy the base net` is only right where OUR base net already matches
golden's.  This scorer lists every `Nets()` entry a holder owns (the inner
element nets are excluded: they are the array_net's, not the holder's) with
its `vpiNetType` and typespec, and diffs golden against ours PER POSITION —
`nets::Compare` reads `VpiNetType` (UHDM generated/src/nets.cpp:277).

  usage: basenet225.py <golden.dump> <ours.dump>
"""
import sys

sys.path.insert(0, __file__.rsplit('/', 1)[0])
import anetcen225 as A  # noqa: E402


def holders(path):
    out = {}

    def walk(n):
        if n.kind in A.HOLDERS:
            full = A.get(n, 'vpiFullName') or A.get(n, 'vpiName') or n.head
            lst = A.kids(n, 'vpiNet')
            if lst and (full not in out or len(lst) > len(out[full])):
                out[full] = lst
        for f, c in n.children:
            if f == 'vpiParent':
                continue
            walk(c)

    for r in A.parse(path):
        walk(r)
    return out


def rows(path):
    r = []
    for h in sorted(holders(path)):
        for i, n in enumerate(holders(path)[h]):
            r.append(('%s[%d]=%s' % (h, i, A.get(n, 'vpiFullName')),
                      '%s nt=%s ts=%s' % (n.kind, A.get(n, 'vpiNetType', '-'),
                                          A.ts_of(n))))
    return r


def main():
    g = dict(rows(sys.argv[1]))
    o = dict(rows(sys.argv[2]))
    miss = sorted(set(g) - set(o))
    extra = sorted(set(o) - set(g))
    diff = sorted(k for k in set(g) & set(o) if g[k] != o[k])
    same = sorted(k for k in set(g) & set(o) if g[k] == o[k])
    for k in miss:
        print('NET-MISSING %s\n  G %s' % (k, g[k]))
    for k in extra:
        print('NET-EXTRA   %s\n  O %s' % (k, o[k]))
    for k in diff:
        print('NET-DIFF    %s\n  G %s\n  O %s' % (k, g[k], o[k]))
    print('NETS MISSING=%d EXTRA=%d DIFF=%d SAME=%d'
          % (len(miss), len(extra), len(diff), len(same)))


if __name__ == '__main__':
    main()
