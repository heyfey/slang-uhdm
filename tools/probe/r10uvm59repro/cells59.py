#!/usr/bin/env python3
"""r10uvm59repro/cells59.py — THE CELL TABLE for a `::`-scoped reference.

    cells59.py <g.dump> <o.dump> [name-regex]

GOLDEN IS ALWAYS argv[1].  Prints, for every dump HEADER line whose object NAME
matches the regex (default: a name containing `::` twice or more, i.e. a scoped
reference inside a scoped fullname), a row keyed on

    (UHDM CLASS, vpiName-bearing fullname, span)

with the MULTIPLICITY on each side, because an object is not a dump occurrence
and a multiplicity change is a differing cell.  Indentation is stripped from the
key (depth is compared separately by msdist.sh, which keeps it).

GUARDS:
  * a missing or empty input is exit 6, never an empty (and therefore
    "identical") table;
  * every row prints BOTH counts, so an absent object shows as `0` rather than
    vanishing from the table;
  * the trailing summary counts DIFFERING cells, and a cell with equal counts
    is still listed when --all is given, so "0 differing" is never inferred from
    a short table.
"""
import re
import sys
from collections import Counter

HDR = re.compile(r'^\s*\\_(\w+): (\([^)]*\))?(.*)$')


def load(path, pat):
    try:
        lines = open(path, 'rt', errors='replace').read().split('\n')
    except OSError as exc:
        sys.exit('NO_OUTPUT: %s (%s)' % (path, exc))
    if not any(l.strip() for l in lines):
        sys.exit('NO_OUTPUT: empty %s' % path)
    c = Counter()
    for l in lines:
        m = HDR.match(l)
        if not m:
            continue
        kind, name, rest = m.group(1), (m.group(2) or ''), m.group(3)
        if not pat.search(name):
            continue
        c[(kind, name, rest.strip())] += 1
    return c


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    args = [a for a in sys.argv[1:] if a != '--all']
    show_all = '--all' in sys.argv
    g_path, o_path = args[0], args[1]
    pat = re.compile(args[2] if len(args) > 2 else r'::.*::')
    g, o = load(g_path, pat), load(o_path, pat)
    keys = sorted(set(g) | set(o))
    diff = 0
    print('%-22s %-72s %-28s %5s %5s' % ('KIND', 'NAME', 'SPAN', 'GOLD', 'OURS'))
    for k in keys:
        gc, oc = g.get(k, 0), o.get(k, 0)
        if gc != oc:
            diff += 1
        if gc != oc or show_all:
            print('%-22s %-72s %-28s %5d %5d%s'
                  % (k[0], k[1][:72], k[2][:28], gc, oc,
                     '' if gc == oc else '   <<< DIFF'))
    print('CELLS: %d total, %d DIFFERING   (golden=%s ours=%s)'
          % (len(keys), diff, g_path, o_path))


if __name__ == '__main__':
    main()
