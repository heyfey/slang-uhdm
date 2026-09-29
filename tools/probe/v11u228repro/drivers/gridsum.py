#!/usr/bin/env python3
"""v11u228: gridsum.py <gridv output>: the summary of drivers/gridv.sh lines (P pristine, L r11u228's law binary,
X the verified binary, XO = X under R11U228_OFF, XV = X under R11V228_OFF, I / S = X with R11V228_ROOTINST_OFF /
R11V228_ROOTSHAPE_OFF): byte identities, exit codes, moves and EQUAL entries/exits."""
import sys
rows = [l.rstrip() for l in open(sys.argv[1])]
def parse(l):
    parts = l.split('|'); d = {}
    for p in parts[1:]:
        p = p.strip()
        if not p: continue
        t = p.split()[0]; kv = dict(x.split('=', 1) for x in p.split()[1:] if '=' in x); d[t] = kv
    return parts[0].strip(), d
eq = lambda k: k.get('strict', '').startswith('STRICT_EQUAL')
c = dict(views=0, XO_ne_P=0, XV_ne_L=0, badrc=0, L_moved=0, X_moved=0, X_ne_L=0, L_in=0, L_out=0, L_cmpout=0,
         X_in=0, X_out=0, X_cmpout=0, I=0, S=0)
for l in rows:
    n, d = parse(l); c['views'] += 1
    g = lambda t, f='md5': d[t].get(f)
    if g('XO') != g('P'): c['XO_ne_P'] += 1; print('XO!=P', n)
    if g('XV') != g('L'): c['XV_ne_L'] += 1; print('XV!=L', n)
    for t in d:
        if d[t].get('rc') not in ('0', None): c['badrc'] += 1; print('RC', t, d[t].get('rc'), n)
    for tag in ('L', 'X'):
        if g(tag) != g('P'):
            c[tag + '_moved'] += 1
            if eq(d[tag]) and not eq(d['P']): c[tag + '_in'] += 1
            if eq(d['P']) and not eq(d[tag]): c[tag + '_out'] += 1; print(tag, 'LEAVES EQUAL', n)
            if g('P', 'cmp') == '0' and g(tag, 'cmp') != '0': c[tag + '_cmpout'] += 1; print(tag, 'LEAVES JUDGE', n)
    if g('X') != g('L'):
        c['X_ne_L'] += 1
        print('X!=L', n, 'P', g('P', 'strict'), 'L', g('L', 'strict'), 'X', g('X', 'strict'),
              '(=P bytes)' if g('X') == g('P') else '', 'I' if g('I') != g('X') else '', 'S' if g('S') != g('X') else '')
    c['I'] += g('I') != g('X'); c['S'] += g('S') != g('X')
print(c)
