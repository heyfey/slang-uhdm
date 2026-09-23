#!/usr/bin/env python3
"""v11u93 name-keyed VALUE cell scorer (measurement only; uhdm-cmp is the judge).
Like r11u107 cell107.py, but a cell's value is KIND + the object's own scalar
fields (vpiDecompile, vpiSize, UINT, vpiConstType, vpiName, vpiPacked, ...),
excluding vpiFullName/vpiFile/vpiRef*/locations.  Keys = section + name path.
  move <dirA-tag> <dirB-tag> <arm-dir>...  (files gold.dump, <tag>.dump)
"""
import re, sys, os
LOCACT = os.environ.get('LOCACT') == '1'
TAIL = os.environ.get('TAIL') == '1'
from collections import defaultdict
OBJ = re.compile(r'^(\s*)\\_([A-Za-z_]+):\s?(.*)$')
FLD = re.compile(r'^(\s*)\|([A-Za-z_]+):(.*)$')
SKIP = {'vpiFullName', 'vpiFile', 'vpiRefFile', 'vpiRefLineNo', 'vpiRefColumnNo',
        'vpiRefEndLineNo', 'vpiRefEndColumnNo', 'vpiLineNo', 'vpiColumnNo',
        'vpiEndLineNo', 'vpiEndColumnNo', 'vpiDefFile', 'vpiDefLineNo'}
def label(rest):
    rest = re.sub(r',? ?(file:[^,]*|line:\d+:\d+|endln:\d+:\d+|id:\d+)', '', rest)
    m = re.search(r'\(([^()]*)\)\s*$', rest)
    if m and m.group(1):
        return m.group(1)
    rest = rest.strip().strip(',').strip()
    return rest if rest else '#'
def norm(v, root):
    return v.replace(root, '<R>') if root else v
def cells(path, root=None):
    out = defaultdict(list)
    stack = []  # (indent, keypart, objrec)
    field = None; section = None
    for ln in open(path, errors='replace'):
        ln = ln.rstrip('\n')
        if ln.startswith('\\_weaklyReferenced'):
            if not TAIL: break
            section = 'WR'; stack = []; field = 'wr'; continue
        if ln.startswith('|') and ln.rstrip().endswith(':') and FLD.match(ln) and FLD.match(ln).group(3) == '':
            section = ln[1:].rstrip(':'); stack = []; field = None
            continue
        m = FLD.match(ln)
        if m:
            ind = len(m.group(1)); name = m.group(2); val = m.group(3)
            if val != '':
                # scalar attribute of the object at indent ind-2
                for (oi, _, rec) in reversed(stack):
                    if oi == ind - 2:
                        if name not in SKIP:
                            rec.append(f'{name}={norm(val, root)}')
                        break
                    if oi < ind - 2:
                        break
                continue
            field = name
            while stack and stack[-1][0] >= ind: stack.pop()
            continue
        m = OBJ.match(ln)
        if not m or section is None:
            continue
        ind = len(m.group(1)); kind = m.group(2)
        while stack and stack[-1][0] >= ind: stack.pop()
        if section == 'WR' and ind == 0: field = 'wr'
        if field in ('vpiParent', 'vpiInstance'):
            continue
        lab = label(norm(m.group(3), root))
        if LOCACT and field == 'vpiActual':
            mm = re.search(r'line:\d+:\d+', m.group(3))
            if mm: kind = kind + '@' + mm.group(0)
        if section == 'WR' and not stack:
            mm = re.search(r'line:\d+:\d+, endln:\d+:\d+', m.group(3))
            lab = lab + '@' + (mm.group(0) if mm else '-')
        kp = str(field) + ':' + lab
        key = section + '/' + '/'.join(p for _, p, _ in stack) + '/' + kp
        rec = [kind]
        out[key].append(rec)
        stack.append((ind, kp, rec))
    D = os.environ.get('DEDUP') == '1'
    return {k: sorted(set('|'.join([r[0]] + sorted(r[1:])) for r in v)) if (D or k.startswith('WR')) else sorted('|'.join([r[0]] + sorted(r[1:])) for r in v) for k, v in out.items()}
def score(g, o):
    G, O = cells(g), cells(o)
    res = {}
    for k in set(G) | set(O):
        gv, ov = G.get(k), O.get(k)
        res[k] = 'OK' if gv == ov else ('GOLD-ONLY' if ov is None else ('OURS-ONLY' if gv is None else 'WRONG'))
    return res, G, O
if __name__ == '__main__':
    a, b = sys.argv[2], sys.argv[3]; mw = gn = ww = 0
    for d in sys.argv[4:]:
        d = d.rstrip('/')
        ra, _, OA = score(f'{d}/gold.dump', f'{d}/{a}.dump')
        rb, GB, OB = score(f'{d}/gold.dump', f'{d}/{b}.dump')
        arm = d.split('/')[-1]
        for k in sorted(set(ra) | set(rb)):
            sa, sb = ra.get(k, 'OK'), rb.get(k, 'OK')
            if sa == 'OK' and sb != 'OK':
                mw += 1; print(f'  MOVED-WRONG {arm} {k}\n     gold={GB.get(k)}\n     {b}={OB.get(k)}')
            elif sa != 'OK' and sb == 'OK':
                gn += 1
                if len(sys.argv) > 0 and __import__('os').environ.get('SHOWGAIN'): print(f'  GAINED {arm} {k}')
            elif sa != 'OK' and sb != 'OK' and OA.get(k) != OB.get(k):
                ww += 1; print(f'  CHANGED-STILL-WRONG {arm} {k}\n     gold={GB.get(k)}\n     {a}={OA.get(k)}\n     {b}={OB.get(k)}')
    print(f'CELL MOVED-WRONG={mw} GAINED={gn} CHANGED-STILL-WRONG={ww} (arms={len(sys.argv)-4}, {a} -> {b})')
