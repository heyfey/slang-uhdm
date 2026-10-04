import sys,collections
rows=collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f=l.split()
    if len(f)<3: continue
    d=dict(x.split('=',1) for x in f[2:] if '=' in x); d['st']=f[2] if '=' not in f[2] else ''
    rows[f[0]][f[1]]=d
c=collections.Counter(); bad=[]
for k,t in sorted(rows.items()):
    m={x:t[x].get('md5') for x in t}
    rc={x:t[x].get('rc') for x in t}
    if any(v!='0' for v in rc.values()): c['rc!=0:'+','.join(sorted(set(rc.values())))]+=1
    if m.get('W')!=m.get('P'): bad.append(('W!=P',k))
    if m.get('O')!=m.get('P'): bad.append(('O!=P',k))
    if m.get('V')!=m.get('L'): bad.append(('V!=L',k))
    if m.get('F')!=m.get('L'):
        c['F!=L']+=1
        res='C' if m.get('C')==m.get('L') else ('T' if m.get('T')==m.get('L') else 'both/none')
        print('FIXMOVE',k,'restored-by',res,'F==P' if m['F']==m['P'] else 'F!=P', t['L'].get('strict'),'->',t['F'].get('strict'), 'cmp',t['L'].get('cmplines'),'->',t['F'].get('cmplines'))
    if m.get('L')!=m.get('P'): c['L!=P']+=1
print(dict(c)); print(bad)
