#!/usr/bin/env python3
"""r11u26 — THE DIRECTIONAL CENSUS, over `idcen26`'s cells.

`idcen26` prints one line per param_assign Rhs (`PA`) and one per
typespec_member `Actual_value` (`TM`), keyed by listing x scope x name, with
the judge-visible payload and with OBJECT IDS.  Ids are per-database interning
order, so they are NOT comparable across databases and are stripped here — the
identity claim is made INSIDE one database (see the README's share proof) and
the directional claim is made on the PAYLOAD.

    dircen26.py <gold.uhdm|gold.idc> <pris...> <pat...>

Prints, per arm:
    SAME  = pristine already equalled golden and still does
    TO    = patched moved a cell TO golden that pristine had wrong
    AWAY  = patched moved a cell AWAY from golden that pristine had right
    MW    = MOVED-WRONG: the cell changed and is still not golden
    SW    = STILL-WRONG: wrong on both binaries, unchanged
plus every AWAY/MW cell spelled out in full, because those are the only two
that can fail a pass.
"""
import re, subprocess, sys, os

IDCEN = os.environ.get('IDCEN', '/tmp/r11u26_idcen')
ID = re.compile(r'#-?\d+')
PARENT = re.compile(r'\s*parent/\S*')


def cells(path):
    if path.endswith('.idc'):
        txt = open(path, errors='replace').read()
    else:
        txt = subprocess.run([IDCEN, path], capture_output=True,
                             text=True).stdout
    out = {}
    for l in txt.split('\n'):
        if not (l.startswith('PA ') or l.startswith('TM ')):
            continue
        parts = l.split(None, 3)
        if len(parts) < 4:
            continue
        tag, listing, name, payload = parts
        # strip every interned id; keep the KINDS, which is the shape
        payload = ID.sub('', payload).strip()
        # ...and drop vpiParent from the SCORED payload: no generated
        # `Compare` reads VpiParent (RESUME.md §9), so a parent difference is
        # invisible to the judge and scoring it manufactured two phantom
        # MOVED-WRONGs on grid `m4`, an arm the official `uhdm-cmp` calls
        # EQUAL.  It is still printed by `idcen26` itself, where the share
        # proof needs it.
        payload = PARENT.sub('', payload).strip()
        out[(tag, listing, name)] = payload
    return out


def one(arm, g, p, q):
    G, P, Q = cells(g), cells(p), cells(q)
    keys = set(G) | set(P) | set(Q)
    same = to = away = mw = sw = 0
    notes = []
    for k in sorted(keys):
        gv, pv, qv = G.get(k), P.get(k), Q.get(k)
        if gv is None or pv is None or qv is None:
            # a cell that exists on one side only is a SHAPE difference; count
            # it as still-wrong unless all three agree it is absent
            if pv == qv:
                sw += 1
            else:
                mw += 1
                notes.append(('MISSING', k, gv, pv, qv))
            continue
        if pv == gv and qv == gv:
            same += 1
        elif pv != gv and qv == gv:
            to += 1
        elif pv == gv and qv != gv:
            away += 1
            notes.append(('AWAY', k, gv, pv, qv))
        elif pv == qv:
            sw += 1
        else:
            mw += 1
            notes.append(('MOVED-WRONG', k, gv, pv, qv))
    print('%-5s SAME=%-3d TO=%-3d AWAY=%-3d MW=%-3d SW=%-3d' %
          (arm, same, to, away, mw, sw))
    for kind, k, gv, pv, qv in notes:
        print('   %s %s' % (kind, k))
        print('      GOLD %s' % gv)
        print('      PRIS %s' % pv)
        print('      PAT  %s' % qv)


if __name__ == '__main__':
    a = sys.argv[1:]
    if len(a) == 1:                      # a grid arm directory
        d = a[0].rstrip('/')
        import glob
        g = glob.glob(os.path.join(d, 'gold', '**', 'surelog.uhdm'),
                      recursive=True)
        one(os.path.basename(d), g[0], os.path.join(d, 'pris.uhdm'),
            os.path.join(d, 'pat.uhdm'))
    else:
        one('arm', a[0], a[1], a[2])
