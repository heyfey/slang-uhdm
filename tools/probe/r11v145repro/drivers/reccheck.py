import sys,os,re,subprocess,glob
sys.path.insert(0,'/tmp/wt_v11u145/scripts')
os.environ.setdefault('SURELOG','/home/heyfey/git-repos/Surelog/build/bin/surelog')
import check_probe as cp, verify_golden as vg
SC='/tmp/v11u145_bin/uhdm-strictcmp'
def gold_row(wd,corpus,mode,name):
    d=glob.glob(f'{wd}/{corpus}/{mode}/{name}-*')
    d=[x for x in d if re.fullmatch(re.escape(name)+r'-[0-9a-f]{8}',os.path.basename(x))]
    assert len(d)==1,(name,d)
    c=open(d[0]+'/cmds.txt').read()
    m=re.search(r'golden cache hit (\S+)\)',c); gd=m.group(1)
    g=[f for f in glob.glob(gd+'/*') if f.endswith('.uhdm')]
    return g[0], d[0]+'/slang.uhdm'
def recs(g,o,tag):
    a=f'/tmp/v11u145_s/rec/{tag}.a'; b=f'/tmp/v11u145_s/rec/{tag}.b'
    r=subprocess.run([SC,'--max','1','--dump-a',a,'--dump-b',b,g,o],capture_output=True,text=True)
    A=open(a).read().split('\n'); B=open(b).read().split('\n')
    return A,B,r.stdout.strip().split('\n')[-1]
out=[]
for l in open('/tmp/v11u145_s/my_changes.txt'):
    p=l.split()
    if p[2] not in ('default','testflags'):  # probe
        rel=p[1]; mode='-'
        g=[f for f in glob.glob(cp.cache_dir(rel)+'/*') if f.endswith('.uhdm')][0]
        fn=rel.replace('/','__')+'.uhdm'
        oP=f'/tmp/v11u145_wdP/probe/{fn}'; oL=f'/tmp/v11u145_wdL/probe/{fn}'
    else:
        name,mode=p[1],p[2]
        corpus='surelog' if os.path.isdir(glob.glob(f'/tmp/v11u145_wdL/surelog/{mode}/{name}-*')[0] if glob.glob(f'/tmp/v11u145_wdL/surelog/{mode}/{name}-*') else '/nonexist') else 'uhdm2rtlil'
        # disambiguate names in both corpora by the sweep's csv
        g,oL=gold_row('/tmp/v11u145_wdL',corpus,mode,name); g2,oP=gold_row('/tmp/v11u145_wdP',corpus,mode,name)
        rel=f'{corpus}/{name}/{mode}'
    tag=rel.replace('/','__')
    Ap,Bp,vp=recs(g,oP,tag+'.P'); Al,Bl,vl=recs(g,oL,tag+'.L')
    n=min(len(Ap),len(Al))
    # divergence = first index where depth/type of A and B mismatch (structural); records compared up to min divergence
    def first_struct(A,B):
        for i in range(min(len(A),len(B))):
            fa=A[i].split('\t')[:2]; fb=B[i].split('\t')[:2]
            if fa!=fb: return i
        return min(len(A),len(B)) if len(A)!=len(B) else None
    dp=first_struct(Ap,Bp); dl=first_struct(Al,Bl)
    lim=min(x for x in [dp,dl,len(Ap),len(Al)] if x is not None)
    Dp={i for i in range(lim) if Ap[i]!=Bp[i]}; Dl={i for i in range(lim) if Al[i]!=Bl[i]}
    new=sorted(Dl-Dp)
    ok = (not new) and (dl is None or dp is None and False or (dp is not None and dl>=dp) or dl is None)
    if dl is not None and dp is None: ok=False
    out.append(f"{'OK ' if ok else 'BAD'} {rel} Adiff P={len(Dp)} L={len(Dl)} newInL={len(new)} divP={dp} divL={dl} | P:{vp} | L:{vl}")
print('\n'.join(out)); print('BAD count', sum(1 for x in out if x.startswith('BAD')), 'of', len(out))
