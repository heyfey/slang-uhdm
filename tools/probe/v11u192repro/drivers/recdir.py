import sys,re
def load(f):
    recs={}; cur=None; tail=''
    for l in open(f):
        m=re.match(r'#(\d+) (\S+)',l)
        if m: cur=m.group(1); recs[cur]={'f':m.group(2)}; continue
        if l.startswith('  A: ') and cur: recs[cur]['A']=l[5:].rstrip('\n')
        elif l.startswith('  B: ') and cur: recs[cur]['B']=l[5:].rstrip('\n')
        else: tail=l.strip() or tail
    return recs,tail
P,pt=load(sys.argv[1]); L,lt=load(sys.argv[2])
fixed=[k for k in P if k not in L]; new=[k for k in L if k not in P]; still=[k for k in L if k in P]
changed=[k for k in still if P[k].get('B')!=L[k].get('B')]
print(f"P:{len(P)} L:{len(L)} fixed={len(fixed)} new={len(new)} stillwrong={len(still)} (of which B changed {len(changed)}) | {pt} -> {lt}")
for k in new: print('  NEW #%s %s\n    A: %s\n    B: %s'%(k,L[k]['f'],L[k].get('A'),L[k].get('B')))
for k in changed: print('  CHG #%s %s\n    A: %s\n    P: %s\n    L: %s'%(k,L[k]['f'],L[k].get('A'),P[k].get('B'),L[k].get('B')))
