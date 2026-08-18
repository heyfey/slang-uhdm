import csv,sys,collections
def load(p):
    d={}
    for r in csv.DictReader(open(p)):
        d[(r['name'],r['mode'])]=(r['status'],r.get('dump',''))
    return d
a=load(sys.argv[1]); b=load(sys.argv[2]); tag=sys.argv[3] if len(sys.argv)>3 else ''
ks=set(a)|set(b); diff=[]
for k in sorted(ks):
    if a.get(k)!=b.get(k): diff.append((k,a.get(k),b.get(k)))
print(f"{tag}: rows A={len(a)} B={len(b)} common={len(set(a)&set(b))} DIFFERING={len(diff)} (status AND dump)")
for k,x,y in diff[:40]: print("   ",k,x,"->",y)
