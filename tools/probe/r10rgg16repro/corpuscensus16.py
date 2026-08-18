import os,re,subprocess,sys,collections
root=sys.argv[1]; out=sys.argv[2]
CEN='/tmp/r10rgg16_pvcensus'
rows=[]; tot=0; withif=0; diffdbs=[]
for d,_,fs in os.walk(root):
    if 'slang.uhdm' not in fs or 'cmds.txt' not in fs: continue
    g=None
    for ln in open(os.path.join(d,'cmds.txt'),errors='replace'):
        m=re.search(r'(/home/\S+/\.cache/slang-uhdm-goldens/[0-9a-f]+)',ln)
        if m: g=m.group(1)+'/golden.uhdm'
    if not g or not os.path.isfile(g): continue
    tot+=1
    def cen(p):
        o=subprocess.run([CEN,p],capture_output=True,text=True,errors='replace')
        dd={}
        for ln in o.stdout.splitlines():
            f=ln.split('\t')
            if len(f)<10: continue
            dd[(f[0],f[1])]=tuple(f[2:])
        return dd
    G=cen(g); O=cen(os.path.join(d,'slang.uhdm'))
    if not G and not O: continue
    withif+=1
    bad=[]
    for k in sorted(set(G)|set(O)):
        if G.get(k)!=O.get(k): bad.append((k,G.get(k),O.get(k)))
    if bad: diffdbs.append((os.path.relpath(d,root),bad))
with open(out,'w') as f:
    f.write('root %s\ndatabases with a golden %d\nwith >=1 interface_inst %d\nDIFFERING %d\n\n'%(root,tot,withif,len(diffdbs)))
    for rel,bad in diffdbs:
        f.write('== %s  (%d differing keys)\n'%(rel,len(bad)))
        for k,a,b in bad[:12]:
            f.write('   %s %s\n      gold %s\n      ours %s\n'%(k[0],k[1],a,b))
print('scanned=%d with_iface=%d differing_dbs=%d'%(tot,withif,len(diffdbs)))
