import re,sys
from collections import Counter
rows=[l.rstrip('\n').split('\t') for l in open(sys.argv[1])]
def p(c):
    m=re.match(r'(\w+):rc=(\S+) cmp=(\S+) dist=(\S+) md5=(\S*) \[(.*)\]',c); return m.groups()
cnt=Counter(); out=[]
for r in rows:
    cols={p(c)[0]:p(c) for c in r[2:]}
    a=cols['pris']; b=cols['law']
    st=lambda x: x[5].split()[0] if x[5] else ''
    if cols['off'][4]!=a[4] or cols['off'][1]!=a[1]: cnt['OFF!=pris']+=1; out.append(('OFFBAD',r[0]))
    if a[4]==b[4]: cnt['identical']+=1; continue
    cnt['movers']+=1
    if a[1]!=b[1]: cnt['rc-change']+=1
    if cols['adm'][4]==a[4]: cnt['adm-restores']+=1
    if cols['frl'][4]!=b[4]: cnt['frl-moves']+=1; out.append(('FRL',r[0],cols['frl'][3],b[3]))
    if st(b)=='STRICT_EQUAL': cnt['toSE']+=1
    elif int(b[3])<int(a[3]): cnt['closer']+=1
    else: cnt['notcloser']+=1; out.append(('NOTCLOSER',r[0]))
    out.append(('MV',r[0],a[1]+'->'+b[1],a[3]+'->'+b[3],st(a)+'->'+st(b)))
for o in out: print(*o)
print(len(rows),cnt)
