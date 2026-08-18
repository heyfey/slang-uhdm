import sys, collections, os, re
def load(W,f):
    p = os.path.join(W,f)
    if not os.path.exists(p): return None
    d = collections.defaultdict(list)
    for line in open(p):
        if not line.startswith('TS '): continue
        a = line.rstrip('\n').split(' ',3)
        k = '|'.join(a[2][4:].split('|')[:-1])
        d[k].append(a[3])
    return {k: sorted(v) for k,v in d.items()}
FIELDS = [('name',  re.compile(r'v=\w+\(([^)]*)\)')),
          ('alias', re.compile(r'\[(alias->[^\]]*|noalias)\]')),
          ('rg',    re.compile(r'(rg=\S+)')),
          ('sg',    re.compile(r'(sg=\S+)')),
          ('inst',  re.compile(r'(inst=\S+)'))]
def fields(v):
    out = {}
    for n,r in FIELDS:
        m = r.search(v); out[n] = m.group(1) if m else None
    return out
tot = collections.Counter()
for W,view in [(sys.argv[i], sys.argv[i+1]) for i in range(1,len(sys.argv),2)]:
    view = '' if view=='.' else view
    G = load(W,'g%s.txt'%('e' if view else '')); O = load(W,'o%s.txt'%view); P = load(W,'p%s.txt'%view)
    for k in sorted(set(G)|set(O)|set(P)):
        g,o,p = G.get(k),O.get(k),P.get(k)
        if o == p: continue          # untouched by the patch
        if g is None:
            tot['NOGOLDEN-moved'] += 1; continue
        n = min(len(g),len(o),len(p))
        for i in range(n):
            fg,fo,fp = fields(g[i]),fields(o[i]),fields(p[i])
            for nm,_ in FIELDS:
                if fo[nm]==fp[nm]: continue
                if fo[nm]!=fg[nm] and fp[nm]==fg[nm]: tot['TO-GOLDEN:'+nm]+=1
                elif fo[nm]==fg[nm] and fp[nm]!=fg[nm]:
                    tot['AWAY:'+nm]+=1
                    print('AWAY %-6s %s\n   G=%s\n   O=%s\n   P=%s' % (nm,W+'/'+(view or 'd')+' '+k,g[i],o[i],p[i]))
                else: tot['STILL:'+nm]+=1
for k in sorted(tot): print('%-22s %d' % (k, tot[k]))
