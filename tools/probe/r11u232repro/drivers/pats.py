#!/usr/bin/env python3
# (r11u232) reads the output of drivers/objid on one database (the caller checks the fence).
# pats.py <objid output>: for every param_assign under a module_inst, the Rhs constant's typespec actual and
# whether that typespec is some io_decl's (formal's) typespec (and whose function).
import sys
rows = {}
for ln in open(sys.argv[1]):
    f = ln.rstrip('\n').split('\t')
    d = {'id': f[0], 'type': f[1], 'name': f[2], 'full': f[3], 'span': f[4]}
    for x in f[5:]:
        if '=' in x:
            k, v = x.split('=', 1); d[k] = v
    rows[f[0]] = d
formal = {}
for r in rows.values():
    if r['type'] == 'io_decl' and r.get('T') in rows:
        a = rows[r['T']].get('A')
        if a:
            fn = rows.get(r.get('P'), {})
            formal.setdefault(a, []).append(f"{fn.get('full','?')}::{r['name']}@{rows.get(fn.get('P'),{}).get('type','?')}{fn.get('P')}")
for r in rows.values():
    if r['type'] != 'param_assign': continue
    par = rows.get(r.get('P'), {})
    if par.get('type') != 'module_inst': continue
    lhs = rows.get(r.get('L'), {}); rhs = rows.get(r.get('R'), {})
    ts = None
    if rhs.get('T') in rows:
        ts = rows[rhs['T']].get('A')
    tsr = rows.get(ts, {})
    print(f"{par.get('full') or par.get('name')}{'' if par.get('TOP')!='1' else '[top]'} {lhs.get('name')} rhs={rhs.get('type')}:{rhs.get('span')} ts={tsr.get('type')}:{tsr.get('name')}:{tsr.get('span')}:P={tsr.get('P')} formal={formal.get(ts, '-')}")
