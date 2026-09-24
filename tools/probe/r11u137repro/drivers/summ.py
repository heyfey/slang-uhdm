import sys,re,os,glob,collections
D=sys.argv[1]; out=open(sys.argv[2],'w')
def rd(f):
    try: return [l.rstrip('\n').split('\x1f')[0].split('\t') for l in open(f,encoding='utf-8',errors='replace')]
    except: return []
FN=['depth','type','name','defname','fullname','file','line','col','endline','endcol','decompile','size','value','consttype','raw']
keyc=collections.Counter(); rowkeys={}
for f in sorted(glob.glob(D+'/*/*/*.out')):
    c,m,n=f.split('/')[-3],f.split('/')[-2],os.path.basename(f)[:-4]
    txt=open(f).read()
    A=rd(f[:-4]+'.a'); B=rd(f[:-4]+'.b')
    last=[l for l in txt.splitlines() if l.startswith('fields') or l.startswith('STRICT')]
    out.write(f'=== {c}/{m}/{n}  {" ".join(last)}\n')
    ks=set()
    for mm in re.finditer(r'^#(\d+) (\S+)',txt,re.M):
        i=int(mm.group(1)); fld=mm.group(2)
        a=A[i] if i<len(A) else []; b=B[i] if i<len(B) else []
        typ=a[1] if len(a)>1 else '?'
        k=f'{fld}|{typ}'
        ks.add(k)
        out.write(f'  #{i} {fld}\n    G: {"|".join(a)[:230]}\n    O: {"|".join(b)[:230]}\n')
    for k in ks: keyc[k]+=1
    rowkeys[(c,m,n)]=ks
out.close()
for k,v in keyc.most_common(60): print(v,k)
