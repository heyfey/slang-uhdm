#!/usr/bin/env python3
"""r10uvm54repro/join.py — join two `tdgroup.py rows` outputs (LHS golden,
RHS ours) on the (owner class, typedef name) key and classify every cell.

LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.

    usage: join.py <golden-rows.txt> <ours-rows.txt> [--all]

Cell classes:
    EQ          span equal AND alias-target equal
    ALIAS_ONLY  span equal, alias differs   (this pass's law: golden has one,
                                             we have NONE)
    SPAN_ONLY   alias equal, span differs
    BOTH        span AND alias differ
    LHS_ONLY / RHS_ONLY  the key exists on one side only

GUARDS: refuses to report when either side parsed 0 rows (exit 4); the
alias comparison is on the (target kind, target name, target span) TRIPLE and
NOT on the ref's own vpiFullName, because that fullname is a KNOWN separate
residue (`pkg::` prefix) and folding it in here would hide every real move.
`--all` prints every row; the default prints only non-EQ rows.
"""
import re
import sys

ROW = re.compile(
    r'^(\S+)\s+(\S+)\s+occ=(\d+)\s+span=(\S+)\s+generic=(\S+)\s+alias=(.*)$')


def load(path):
    rows = {}
    for ln in open(path, 'rt', errors='replace'):
        m = ROW.match(ln.rstrip('\n'))
        if not m:
            continue
        rows[(m.group(1), m.group(2))] = {
            'span': m.group(4), 'generic': m.group(5),
            'alias': m.group(6).strip()}
    return rows


def alias_target(a):
    """Drop the ref's own vpiFullName (first token) — a KNOWN separate residue."""
    if a == 'NONE':
        return 'NONE'
    parts = a.split(None, 1)
    return parts[1] if len(parts) > 1 else a


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(2)
    g = load(sys.argv[1])
    o = load(sys.argv[2])
    showall = '--all' in sys.argv
    if not g or not o:
        print('UNMEASURED: golden rows=%d ours rows=%d — one side parsed '
              'NOTHING, this is not a clean answer' % (len(g), len(o)))
        sys.exit(4)
    cls = {}
    for k in sorted(set(g) | set(o)):
        if k not in o:
            c = 'LHS_ONLY'
        elif k not in g:
            c = 'RHS_ONLY'
        else:
            se = g[k]['span'] == o[k]['span']
            ae = alias_target(g[k]['alias']) == alias_target(o[k]['alias'])
            c = ('EQ' if se and ae else 'ALIAS_ONLY' if se else
                 'SPAN_ONLY' if ae else 'BOTH')
        cls[k] = c
        if c == 'EQ' and not showall:
            continue
        print('%-10s %-46s %-16s' % (c, k[0], k[1]))
        if k in g:
            print('    LHS golden span=%-22s alias=%s'
                  % (g[k]['span'], g[k]['alias']))
        if k in o:
            print('    RHS ours   span=%-22s alias=%s'
                  % (o[k]['span'], o[k]['alias']))
    hist = {}
    for c in cls.values():
        hist[c] = hist.get(c, 0) + 1
    print('== joined keys=%d  ' % len(cls) +
          '  '.join('%s=%d' % (c, hist[c]) for c in sorted(hist)))


main()
