import sys,re,collections
rows=collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f=l.split()
    if len(f)<3: continue
    d=dict(x.split('=',1) for x in f[2:] if '=' in x)
    d['raw']=l.strip()
    rows[f[0]][f[1]]=d
base=sys.argv[2] if len(sys.argv)>2 else 'P'; new=sys.argv[3] if len(sys.argv)>3 else 'L'
st=collections.Counter()
for k,t in sorted(rows.items()):
    if base not in t or new not in t: continue
    a,b=t[base],t[new]
    if 'md5' not in a or 'md5' not in b: st['fail']+=1; continue
    if 'Q' in t and 'md5' in t['Q'] and t['Q']['md5']!=t.get('L',{}).get('md5'): print('BRIDGE-L',k)
    if 'R' in t and 'md5' in t['R'] and t['R']['md5']!=t['P']['md5']: print('BRIDGE-P',k)
    if 'O' in t and t['O'].get('md5')!=t['P'].get('md5'): print('OFF-NOT-PRISTINE',k)
    if a['md5']==b['md5']: st['same']+=1; continue
    st['moved']+=1
    sa,sb=a['strict'],b['strict']
    ca,cb=a['cmplines'],b['cmplines']
    tag=''
    if ca=='0' and cb!='0': tag='JUDGE-BREAK'
    elif 'STRICT_EQUAL' in sa and 'STRICT_EQUAL' not in sb: tag='STRICT-BREAK'
    elif 'STRICT_EQUAL' in sb and 'STRICT_EQUAL' not in sa: tag='ENTER-EQUAL'
    elif sa!=sb: tag='CHANGE'
    print(tag or 'move', k, 'cmp',ca,'->',cb, sa,'->',sb)
print(dict(st))
