import sys,subprocess,difflib,collections
g,a,b=sys.argv[1:4]; SC='/tmp/v11u125_bin/uhdm-strictcmp'
F='depth type name defname fullname file line col endline endcol decompile size value consttype'.split()
for t,u in (('P',a),('L',b)):
    subprocess.run([SC,'--max','0','--dump-a','/tmp/v11u125_fd.g','--dump-b','/tmp/v11u125_fd.'+t,g,u],capture_output=True)
R=lambda p:[l.rstrip('\n').split('\t') for l in open(p)]
G=R('/tmp/v11u125_fd.g')
for t in 'PL':
    O=R('/tmp/v11u125_fd.'+t); k=lambda r:'\t'.join(r[:4])
    sm=difflib.SequenceMatcher(None,[k(r) for r in G],[k(r) for r in O],autojunk=False); c=collections.Counter(); objs=0; unp=len(G)+len(O)
    for x,y,n in sm.get_matching_blocks():
        unp-=2*n
        for i in range(n):
            d=[f for j,f in enumerate(F) if (G[x+i][j] if j<len(G[x+i]) else '')!=(O[y+i][j] if j<len(O[y+i]) else '')]
            objs+=bool(d)
            for f in d: c[f]+=1
    print(t,'objects',objs,dict(c),'unpaired',unp)
