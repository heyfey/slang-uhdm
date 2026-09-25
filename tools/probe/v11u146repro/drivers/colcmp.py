import csv,sys
# colcmp.py <a.csv> <b.csv> [probe]: rows whose status/strict differ
def load(f):
    d={}
    for r in csv.reader(open(f)):
        if not r or r[0] in ('name','case'): continue
        if len(r)>=6: d[(r[0],r[1])]=(r[2],r[5])
        else: d[(r[0],)]=(r[1],r[3] if len(r)>3 else '')
    return d
a=load(sys.argv[1]); b=load(sys.argv[2])
ks=sorted(set(a)|set(b))
n=0
for k in ks:
    if a.get(k)!=b.get(k):
        n+=1; print('/'.join(k), a.get(k), '->', b.get(k))
print('changed', n, 'of', len(ks), file=sys.stderr)
