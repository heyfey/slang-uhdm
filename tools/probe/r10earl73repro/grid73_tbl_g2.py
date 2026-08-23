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
def brief(p):
    if p is None: return 'ABSENT'
    m=re.search(r'\|\| (\S+) (.*)$', p); kind=m.group(1); rest=m.group(2)
    if kind!='constant': return kind+' '+rest
    return 'ct%-2s sz%-3s %-22s dec=%s'%(re.search(r'ct=(\d+)',rest).group(1),re.search(r'sz=(-?\d+)',rest).group(1),re.search(r'val=(\S+)',rest).group(1),re.search(r'dec=(\S+)',rest).group(1))
for (chain,name) in sorted(G):
    m=re.search(r'module_inst\((u_\w+)\)$',chain)
    if not m or name!='P': continue
    g=G[(chain,name)]; o=O.get((chain,name))
    gs=brief(g[0]); os_=brief(o[0]) if o else 'ABSENT'
    print('%-12s G: %-46s O: %-46s%s'%(m.group(1),gs,os_,'' if gs==os_ else ' <<<'))
