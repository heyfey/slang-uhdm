import csv,sys,os,glob,re
# list STRICT_NOTEQUAL rows in a sweep workdir: corpus mode name golden ours
wd=sys.argv[1]
for c in ('surelog','uhdm2rtlil'):
    for r in csv.DictReader(open(f'{wd}/{c}.csv')):
        if r['status']!='STRICT_NOTEQUAL': continue
        ds=glob.glob(f"{wd}/{c}/{r['mode']}/{r['name']}-*")
        ds=[d for d in ds if re.fullmatch(re.escape(r['name'])+r'-[0-9a-f]{8}',os.path.basename(d))]
        if len(ds)!=1: print('#MISS',c,r['mode'],r['name'],file=sys.stderr); continue
        d=ds[0]; cmds=open(d+'/cmds.txt').read()
        m=re.search(r'golden cache hit (\S+?)\)?\s',cmds)
        g=m.group(1) if m else ''
        if os.path.isdir(g):
            gg=glob.glob(g+'/*.uhdm'); g=gg[0] if gg else g
        print(c,r['mode'],r['name'],g,d+'/slang.uhdm',sep='\t')
