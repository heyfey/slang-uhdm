import re, sys
def scan(path):
    lines=open(path).read().split('\n')
    scope='?'; res=[]
    for i,l in enumerate(lines):
        m=re.search(r'\\_(function|task): \((work@[\w.:]+)\)',l)
        if m and lines[i-1].strip()=='|vpiTaskFunc:': scope=m.group(2)
        m=re.search(r'\\_io_decl: \((\w+)\)',l)
        if m and lines[i-1].strip()=='|vpiIODecl:':
            has=any('|vpiTypedef:' in lines[j] for j in range(i+1,min(i+9,len(lines))))
            res.append((scope,m.group(1),has))
    return res
bad=0
for arm in sys.argv[1:]:
    g=scan('/tmp/r10fiot_arm/%s/gn.txt'%arm); o=scan('/tmp/r10fiot_arm/%s/on.txt'%arm)
    gd={(a,b):c for a,b,c in g}; od={(a,b):c for a,b,c in o}
    m=[(k,gd[k],od.get(k)) for k in gd if k[0]!='?' and gd[k]!=od.get(k)]
    bad+=len(m)
    print(arm, 'io_decl-ts mismatch:', m if m else 'NONE')
print('TOTAL mismatches', bad)
