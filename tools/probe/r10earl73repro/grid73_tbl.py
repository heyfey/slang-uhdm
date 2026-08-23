import sys, re, collections
def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        f = ln.rstrip('\n').split(' ')
        if f[0]!='PA': continue
        d[(f[1], f[2])].append(' '.join(f[3:]))
    for k in d: d[k].sort()
    return d
G=load(sys.argv[1]); O=load(sys.argv[2])
pat=re.compile(r'module_inst\(u_([a-z]+)_([a-z0-9]+)\)$')
rows={}
for (chain,name),v in G.items():
    m=pat.search(chain)
    if not m or name!='P': continue
    rows[(m.group(1),m.group(2))]=(v, O.get((chain,name)))
def brief(p):
    if p is None: return 'ABSENT'
    m=re.search(r'\|\| (\S+) (.*)$', p)
    kind=m.group(1); rest=m.group(2)
    if kind!='constant': return kind+' '+rest
    ct=re.search(r'ct=(\d+)',rest).group(1); sz=re.search(r'sz=(-?\d+)',rest).group(1)
    val=re.search(r'val=(\S+)',rest).group(1); dec=re.search(r'dec=(\S+)',rest).group(1)
    return 'ct%-2s sz%-3s %-14s dec=%s'%(ct,sz,val,dec)
order=['none','lit','blit','hlit','refa','div','mul','sub','add','shl','shr','clog','tern','cast','conc','neg','mod','band','bxor','eq','pow','tpow','divl','mulm']
types=['int','unt','bitr','logr','itg','sgn']
for t in types:
    print('== declared: %s'%t)
    for s in order:
        k=(t,s)
        if k not in rows: continue
        g,o=rows[k]
        gs=brief(g[0]); os_=brief(o[0]) if o else 'ABSENT'
        flag='' if gs==os_ else '   <<< DIFF'
        print('  %-5s G: %-45s O: %-45s%s'%(s,gs,os_,flag))
