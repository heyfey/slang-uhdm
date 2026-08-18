import sys, collections, os
W = sys.argv[1]; suffix = sys.argv[2] if len(sys.argv)>2 else ''   # '' = default view, 'e' = elab
LOCKEY = os.environ.get('LOCKEY','0') == '1'
def load(f):
    p = os.path.join(W,f)
    if not os.path.exists(p): return None
    d = collections.defaultdict(list)
    for line in open(p):
        if not line.startswith('TS '): continue
        a = line.rstrip('\n').split(' ',3)
        k = a[2][4:]
        if not LOCKEY:
            k = '|'.join(k.split('|')[:-1])
        d[k].append(a[3])
    return {k: sorted(v) for k,v in d.items()}
G = load('g%s.txt'%('e' if suffix else ''))
O = load('o%s.txt'%suffix); P = load('p%s.txt'%suffix)
ks = sorted(set(G)|set(O)|set(P or {}))
same=conv=over=res=msw=0
for k in ks:
    g,o,p = G.get(k),O.get(k),P.get(k) if P else None
    if g==o==p: same+=1; continue
    if g!=o and g==p: v='CONVERTED'; conv+=1
    elif g==o and g!=p: v='OVER-FIRE'; over+=1
    elif g!=o and o==p: v='residue'; res+=1
    else: v='MOVED-STILL-WRONG'; msw+=1
    print('%-18s %s\n    G=%s\n    O=%s\n    P=%s' % (v,k,g,o,p))
print('-- VIEW %s CELLS %d same %d CONVERTED %d OVER-FIRE %d MOVED-STILL-WRONG %d residue %d'
      % (suffix or 'default', len(ks), same, conv, over, msw, res))
