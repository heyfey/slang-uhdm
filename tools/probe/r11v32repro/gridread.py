#!/usr/bin/env python3
"""v11u32 independent grid reader.

Written from scratch (NOT derived from the implementer's gridread.py) so the
two instruments can be cross-checked against each other on the same dumps.

Model of the uhdm-dump text, verified against a real dump before use:
  * an object line is `<indent>\\_<kind>: (<fullname>), ...`  (the very first
    object of a section has no `\\_` prefix)
  * a field line is `<indent>|<Field>:<value>`
  * a field at indent J belongs to the closest preceding object line whose
    indent is < J.  (Fields sit exactly 2 deeper than their owner, but using
    "<" instead of "== owner+2" makes the reader independent of that.)
Sections: DEF  = from the line `|uhdmallModules:` to `|uhdmtopModules:`
          ELAB = from `|uhdmtopModules:` to `\\_weaklyReferenced:` (tail dropped)
"""
import re
import sys

OBJ = re.compile(r'^(\s*)\\?_?([A-Za-z_0-9]+): \(([^)]*)\)')
FLD = re.compile(r'^(\s*)\|([A-Za-z]+):(.*)$')


def split_sections(path):
    lines = open(path, errors='replace').read().split('\n')
    d = e = t = None
    for i, l in enumerate(lines):
        s = l.strip()
        if s == '|uhdmallModules:' and d is None:
            d = i
        elif s == '|uhdmtopModules:' and e is None:
            e = i
        elif s.startswith('\\_weaklyReferenced:') and t is None:
            t = i
    n = len(lines)
    return lines[(d if d is not None else 0):(e if e is not None else n)], \
        lines[(e if e is not None else n):(t if t is not None else n)]


def harvest(lines, pref):
    """-> {leafname: (kind, nettype-or-None)} first (outermost/earliest) sighting."""
    res = {}
    owners = []          # (indent, leafname, kind)
    for l in lines:
        mo = OBJ.match(l)
        if mo:
            ind = len(mo.group(1))
            kind = mo.group(2)
            leaf = mo.group(3).split('.')[-1]
            while owners and owners[-1][0] >= ind:
                owners.pop()
            owners.append((ind, leaf, kind))
            if leaf.startswith(pref) and leaf not in res:
                res[leaf] = [kind, None]
            continue
        mf = FLD.match(l)
        if not mf:
            continue
        ind = len(mf.group(1))
        name, val = mf.group(2), mf.group(3).strip()
        while owners and owners[-1][0] >= ind:
            owners.pop()
        if not owners:
            continue
        oind, oleaf, okind = owners[-1]
        if name == 'vpiNetType' and oleaf.startswith(pref) and oleaf in res \
                and res[oleaf][0] == okind and res[oleaf][1] is None:
            res[oleaf][1] = val
    return {k: tuple(v) for k, v in res.items()}


def main():
    g, o, pref = sys.argv[1], sys.argv[2], (sys.argv[3] if len(sys.argv) > 3 else 'y_')
    gd, ge = split_sections(g)
    od, oe = split_sections(o)
    GD, GE = harvest(gd, pref), harvest(ge, pref)
    OD, OE = harvest(od, pref), harvest(oe, pref)
    names = sorted(set(GD) | set(OD) | set(GE) | set(OE))
    nd = ne = 0
    print(f'{"ARM":24s} | {"DEF golden":22s} | {"DEF ours":22s} | '
          f'{"ELAB golden":18s} | {"ELAB ours":18s} | VERDICT')
    for n in names:
        a = GD.get(n, ('-', None))
        b = OD.get(n, ('-', None))
        c = GE.get(n, ('-', None))
        d = OE.get(n, ('-', None))
        vd = '' if a == b else 'DEF-DIFF'
        ve = '' if c[0] == d[0] else 'ELAB-DIFF'
        nd += bool(vd)
        ne += bool(ve)
        print(f'{n:24s} | {a[0]+" nt="+str(a[1]):22s} | {b[0]+" nt="+str(b[1]):22s} | '
              f'{c[0]:18s} | {d[0]:18s} | {vd} {ve}')
    print(f'-- arms: {len(names)}   DEF-DIFF: {nd}   ELAB-DIFF: {ne}')


main()
