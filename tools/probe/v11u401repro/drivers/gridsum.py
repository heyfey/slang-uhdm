import re,collections,sys
rows=collections.defaultdict(dict)
for l in open(sys.argv[1]):
    p=l.split(None,3); rows[(p[0],p[1])][p[2]]=p[3].strip()
for k in sorted(rows):
    r=rows[k]; pr=r.get('pristine',''); lw=r.get('law','')
    md=lambda s: re.sub(r'.*md5=','',s) if 'md5=' in s else s
    strip=lambda s: re.sub(r' md5=\S+','',s)
    flag='' if md(pr)==md(lw) else 'MOVED'
    offs=' '.join(f"{lab[4:]}:{'=P' if md(v)==md(pr) else '=L' if md(v)==md(lw) else 'X'}" for lab,v in sorted(r.items()) if lab.startswith('law+'))
    print(k[0],k[1],'|',strip(pr),'->',strip(lw),'|',flag,offs)
