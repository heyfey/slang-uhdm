import sys
def load(f):
    d={}
    for l in open(f):
        p=l.split(' ',1)
        if len(p)==2: d[p[0]]=p[1].strip()
    return d
a=load(sys.argv[1]); b=load(sys.argv[2])
for k in sorted(set(a)|set(b)):
    x=a.get(k,'-'); y=b.get(k,'-')
    m='same' if x.split('md5=')[-1]==y.split('md5=')[-1] else 'MOVED'
    print(k.replace('v11u450repro_cases_',''),'|',x,'|',y,'|',m)
