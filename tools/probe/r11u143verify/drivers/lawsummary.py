#!/usr/bin/env python3
"""lawsummary.py: per-law counts from evidence/table_{default,elab}.tsv."""
import collections, os
E=os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','evidence')
def tab(f): return [l.rstrip('\n').split('\t') for l in open(os.path.join(E,f))]
D={p[0]:p for p in tab('table_default.tsv')}; X={p[0]:p for p in tab('table_elab.tsv')}
S=collections.OrderedDict()
for k,p in D.items():
    s=S.setdefault(p[2],collections.Counter()); s['cases']+=1
    for m,x in (('d',p),('e',X[k])):
        v=x[5]; s[m+'_je']+=x[3]=='equal' or x[3].startswith('ne:'); s[m+'_eq']+=x[3]=='equal'
        t='T' if v.startswith('TURNED') else '-' if v.startswith('SAME') else 'S' if v.startswith('STAGE1') else 'B' if (v.startswith('OK') or v.startswith('EQUAL-both')) else 'U' if v.startswith('GROW') else 'X'
        s[m+t]+=1
print('law\tcases\tdefault: judge-eq/strict-eq at base | T turned B better U unmask S stage1-moved - untouched X other\t--elabuhdm: same')
tot=collections.Counter()
for l,s in S.items():
    tot+=s
    f=lambda m: f"{s[m+'_je']}/{s[m+'_eq']} T{s[m+'T']} B{s[m+'B']} U{s[m+'U']} S{s[m+'S']} -{s[m+'-']} X{s[m+'X']}"
    print(f"{l}\t{s['cases']}\t{f('d')}\t{f('e')}")
print('TOTAL',{k:v for k,v in sorted(tot.items())})
