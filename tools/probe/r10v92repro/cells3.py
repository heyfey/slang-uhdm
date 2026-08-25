import sys, os, collections
def load(p):
    rows = collections.defaultdict(list)
    if not os.path.exists(p): return rows
    for ln in open(p):
        ln = ln.rstrip('\n')
        if not ln.startswith('CA\t'): continue
        k, _, pay = ln.partition('\t||\t')
        f = dict(x.split('=', 1) for x in k.split('\t')[1:])
        pay, _, diag = pay.partition('\tDIAG\t')
        g = dict(x.split('=', 1) for x in pay.split('\t'))
        g.update(dict(x.split('=', 1) for x in diag.split('\t')) if diag else {})
        key = (f['LSPAN'], f['LNAME'], f['VIEW'], f['INST'])
        rows[key].append('%s:%s@%s %s' % (g['RK'], g['ROP'], g.get('RSPAN','-'), g['ROPK']))
    for v in rows.values(): v.sort()
    return rows
def verdict(g,o,x):
    if g==o==x: return 'SAME'
    if g==x and g!=o: return 'FIXED'
    if g==o and g!=x: return 'BROKE'
    if o==x: return 'DIFF-UNMOVED'
    return 'DIFF-MOVED'
tot=collections.Counter()
for d in sys.argv[1:]:
    G,O,Q,R = (load(os.path.join(d,f)) for f in ('g.rows','o.rows','q.rows','r.rows'))
    for k in sorted(set(G)|set(O)|set(Q)|set(R)):
        g,o,q,r = G.get(k,[]),O.get(k,[]),Q.get(k,[]),R.get(k,[])
        vq, vr = verdict(g,o,q), verdict(g,o,r)
        tot[('patched',vq)]+=1; tot[('fixed',vr)]+=1
        if vq!='SAME' or vr!='SAME':
            print('%-24s %-5s %-11s %-16s patched=%-14s fixed=%s' % (os.path.basename(d),k[2],k[0],k[1],vq,vr))
print('--- TOTALS ---')
for side in ('patched','fixed'):
    print(side, ' '.join('%s=%d'%(v,n) for (s,v),n in sorted(tot.items()) if s==side))
