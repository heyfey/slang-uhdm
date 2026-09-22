#!/usr/bin/env python3
# v11u93 INDEPENDENT class-listing scorer (verifier's own; does not reuse the
# implementer's classcell98.py).  Reads a uhdm-dump and extracts, per HOLDER,
# the ORDERED list of class_defn entries under vpiClassDefn / uhdmallClasses.
# Scores CELL (holder,index) and SUBTREE (holder,name) against golden.
import re, sys

OBJ = re.compile(r'^(\s*)\\_([A-Za-z_0-9]+): (.*)$')
REL = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):\s*$')

def parse(path):
    listings = {}   # holder -> [class fullname, ...]
    obj_at = {}
    rel_at = {}
    for raw in open(path, errors='replace'):
        line = raw.rstrip('\n')
        m = REL.match(line)
        if m:
            ind = len(m.group(1)); rel_at[ind] = m.group(2)
            continue
        m = OBJ.match(line)
        if not m:
            continue
        ind = len(m.group(1)); kind = m.group(2); rest = m.group(3)
        lbl = rest.split(',')[0].strip()
        obj_at[ind] = kind + ' ' + lbl
        r = rel_at.get(ind)
        if r in ('vpiClassDefn', 'uhdmallClasses') and kind == 'class_defn':
            holder = obj_at.get(ind - 2, 'DESIGN') if r == 'vpiClassDefn' else 'DESIGNROOT'
            listings.setdefault(holder + '|' + r, []).append(lbl)
        # a NON-class object under the relation resets nothing
        for k in list(rel_at):
            if k > ind:
                del rel_at[k]
        for k in list(obj_at):
            if k > ind:
                del obj_at[k]
    return listings

def score(gold, ours):
    g = parse(gold); o = parse(ours)
    cell_ok = cell_diff = cell_gold = cell_ours = 0
    sub_match = sub_gold = sub_ours = 0
    rows = []
    for h in sorted(set(g) | set(o)):
        gl = g.get(h, []); ol = o.get(h, [])
        n = max(len(gl), len(ol))
        for i in range(n):
            gv = gl[i] if i < len(gl) else None
            ov = ol[i] if i < len(ol) else None
            if gv is None:
                cell_ours += 1; rows.append(f'CELL-OURS-ONLY {h}[{i}] ours={ov}')
            elif ov is None:
                cell_gold += 1; rows.append(f'CELL-GOLD-ONLY {h}[{i}] gold={gv}')
            elif gv == ov:
                cell_ok += 1
            else:
                cell_diff += 1; rows.append(f'CELL-DIFF {h}[{i}] gold={gv} ours={ov}')
        gs = {}; os_ = {}
        for v in gl: gs[v] = gs.get(v, 0) + 1
        for v in ol: os_[v] = os_.get(v, 0) + 1
        for k in set(gs) | set(os_):
            a, b = gs.get(k, 0), os_.get(k, 0)
            sub_match += min(a, b)
            if a > b:
                sub_gold += a - b; rows.append(f'SUB-GOLD-ONLY {h} {k} x{a-b}')
            if b > a:
                sub_ours += b - a; rows.append(f'SUB-OURS-ONLY {h} {k} x{b-a}')
    return dict(cell_ok=cell_ok, cell_diff=cell_diff, cell_gold=cell_gold,
                cell_ours=cell_ours, sub_match=sub_match, sub_gold=sub_gold,
                sub_ours=sub_ours), rows

if __name__ == '__main__':
    st, rows = score(sys.argv[1], sys.argv[2])
    print(' '.join(f'{k}={v}' for k, v in st.items()))
    if len(sys.argv) > 3 and sys.argv[3] == '--rows':
        for r in rows:
            print('   ' + r)
