#!/usr/bin/env python3
"""r11u107 NAME-KEYED cell scorer (measurement only; uhdm-cmp is the judge).

Every object line of a `uhdm-dump` is a cell keyed by its NAME PATH: the
top-level section plus, per level, `field/<label>` where label is the object's
`(fullname)` / name token when it has one and `#` otherwise (so a listing
reorder or a surplus sibling does not shift the key the way a positional slot
does).  The cell value is the object KIND.  Keys collide (unnamed siblings):
the value is the SORTED MULTISET of kinds under that key.  Spans, ids and the
weaklyReferenced tail are ignored.

  score : cell107.py score <gold.dump> <ours.dump>
  move  : cell107.py move <tagA> <tagB> <arm-dir>...   (gold.<tag>.dump, ours.<tag>.dump)
"""
import re, sys
from collections import defaultdict
OBJ = re.compile(r'^(\s*)\\_([A-Za-z_]+):\s?(.*)$')
FLD = re.compile(r'^(\s*)\|([A-Za-z_]+):\s*$')
def label(rest):
    rest = re.sub(r',? ?(file:[^,]*|line:\d+:\d+|endln:\d+:\d+)', '', rest)
    m = re.search(r'\(([^()]*)\)\s*$', rest)
    if m and m.group(1):
        return m.group(1)
    rest = rest.strip()
    return rest if rest else '#'
def cells(path):
    out = defaultdict(list)
    stack = []  # (indent, keypart)
    field = None; fdepth = -1; section = None
    for ln in open(path, errors='replace'):
        ln = ln.rstrip('\n')
        if ln.startswith('\\_weaklyReferenced'):
            break
        if ln.startswith('|'):
            section = ln[1:].rstrip(':'); stack = []; field = None
            continue
        m = FLD.match(ln)
        if m:
            ind = len(m.group(1)); field = m.group(2)
            while stack and stack[-1][0] >= ind: stack.pop()
            continue
        m = OBJ.match(ln)
        if not m or section is None:
            continue
        ind = len(m.group(1)); kind = m.group(2)
        while stack and stack[-1][0] >= ind: stack.pop()
        if field == 'vpiParent' or field == 'vpiInstance':
            continue
        key = section + '/' + '/'.join(p for _, p in stack) + '/' + str(field) + ':' + label(m.group(3))
        out[key].append(kind)
        stack.append((ind, str(field) + ':' + label(m.group(3))))
    return {k: sorted(v) for k, v in out.items()}
def score(g, o):
    G, O = cells(g), cells(o)
    res = {}
    for k in set(G) | set(O):
        gv, ov = G.get(k), O.get(k)
        res[k] = 'OK' if gv == ov else ('GOLD-ONLY' if ov is None else ('OURS-ONLY' if gv is None else 'WRONG'))
    return res, G, O
if __name__ == '__main__':
    if sys.argv[1] == 'score':
        r, _, _ = score(sys.argv[2], sys.argv[3])
        c = defaultdict(int)
        for v in r.values(): c[v] += 1
        print(dict(c))
    elif sys.argv[1] == 'move':
        a, b = sys.argv[2], sys.argv[3]; mw = gn = 0
        for d in sys.argv[4:]:
            d = d.rstrip('/')
            ra, _, OA = score(f'{d}/gold.{a}.dump', f'{d}/ours.{a}.dump')
            rb, GB, OB = score(f'{d}/gold.{b}.dump', f'{d}/ours.{b}.dump')
            for k in sorted(set(ra) | set(rb)):
                sa, sb = ra.get(k, 'OK'), rb.get(k, 'OK')
                if sa == 'OK' and sb != 'OK':
                    mw += 1; print(f'  MOVED-WRONG {d.split("/")[-1]} {k} gold={GB.get(k)} ours={OB.get(k)}')
                elif sa != 'OK' and sb == 'OK':
                    gn += 1; print(f'  GAINED {d.split("/")[-1]} {k} {GB.get(k)}')
        print(f'CELL MOVED-WRONG={mw} GAINED={gn} (arms={len(sys.argv)-4}, {a} -> {b})')
