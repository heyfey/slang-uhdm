#!/usr/bin/env python3
"""lawtable.py: the per-law markdown tables of the README from evidence/ (table_default.tsv, table_elab.tsv,
downstream_cases.jsonl, battery_*: other switches that move a case)."""
import json, collections, os, re, sys
E=os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','evidence')
def tab(f):
    d={}
    for l in open(os.path.join(E,f)):
        p=l.rstrip('\n').split('\t'); d[p[0]]=p
    return d
TD,TE=tab('table_default.tsv'),tab('table_elab.tsv')
DS=collections.defaultdict(dict)
for l in open(os.path.join(E,'downstream_cases.jsonl')):
    r=json.loads(l); DS['/'.join(r['case'].split('/')[-2:])][r['tag']]=r['verdict']
def short(v):
    if not v: return '-'
    v=v.split(' || ')[0].split(' P=')[0]
    if v.startswith('STAGE1-both'):
        m=re.search(r'P_dist=(\d+) L_dist=(\d+)',v); return f'stage1 both, dump distance {m.group(1)}→{m.group(2)}' if m else 'stage1 both'
    return {'SAME':'untouched','TURNED':'**turned equal**'}.get(v,v)
laws=collections.OrderedDict()
for k,p in TD.items(): laws.setdefault(p[2],[]).append(k)
for law,cs in laws.items():
    print(f'\n#### {law}\n\n| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |\n|---|---|---|---|---|---|---|')
    for c in sorted(cs):
        d=TD[c]; e=TE.get(c,['']*9); ds=DS.get(c,{})
        dss=ds.get('ON','?') if len(set(ds.values()))<=1 else f"{ds.get('ON')}; {ds.get('OWN')}; {ds.get('A3')}"
        print(f'| {c} | {d[3]} | {d[4]} → {d[3]}: {short(d[5])} | {e[3]} | {short(e[5])} | {short(d[7])} | {dss} |')
