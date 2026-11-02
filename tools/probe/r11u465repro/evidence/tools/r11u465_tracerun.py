# traced census: run BIN over candidate rows (our side only), trace per row into OUT/<key>/
import os,sys,subprocess,glob,shlex,concurrent.futures as cf
BIN,OUT=sys.argv[1],sys.argv[2]
fen=[l.strip() for l in open('/tmp/r11u465_fenced.txt') if l.strip()]
def bad(p): return any(f in p for f in fen)
root='/home/heyfey/git-repos/slang-uhdm'; ctl='/tmp/intr11u462'
cands=set()
for f in ('/tmp/r11u465_census.txt','/tmp/r11u465_census2.txt'):
    for l in open(f):
        t=l.split()
        if t: cands.add((t[0],t[1]))
jobs=[]
for corp,n in sorted(cands):
    if bad(n): continue
    if corp=='probe':
        d=os.path.join(root,'tests/probe',os.path.dirname(n) if n.endswith('.sv') else n)
        jobs.append(('probe/'+os.path.relpath(d,root+'/tests/probe'),d,['dut.sv','--single-unit','--nobuiltin']))
    elif corp=='svtests':
        c=os.path.join(ctl,'svtests/work',n,'cmds.txt')
        line=[l for l in open(c) if l.startswith('slang:')][0].split()[1:]
        a=line[1:]; i=a.index('-o'); a=a[:i]+a[i+2:]
        jobs.append(('svtests/'+n,'/tmp',a))
    else:
        bases=[root+'/third_party/Surelog/tests',root+'/third_party/Surelog/third_party/tests'] if corp=='surelog' else [root+'/third_party/uhdm2rtlil/test']
        d=[b+'/'+n for b in bases if os.path.isdir(b+'/'+n)][0]
        for mode in ('default','testflags'):
            for c in glob.glob(f'{ctl}/{corp}/{mode}/{n}-*/cmds.txt'):
                line=[l for l in open(c) if l.startswith('slang:')]
                if not line: continue
                a=line[0].split()[2:]; i=a.index('-o'); a=a[:i]+a[i+2:]
                jobs.append((f'{corp}/{mode}/{n}',d,a))
def run(j):
    key,cwd,a=j; td=os.path.join(OUT,key.replace('/','__')); os.makedirs(td,exist_ok=True)
    env=dict(os.environ,R11U465_TRACE=td)
    r=subprocess.run([BIN]+a+['-o',td+'/out.uhdm'],cwd=cwd,env=env,capture_output=True,stdin=subprocess.DEVNULL,timeout=900)
    try: os.unlink(td+'/out.uhdm')
    except: pass
    n=sum(1 for f in os.listdir(td) for _ in open(os.path.join(td,f)))
    return key,r.returncode,n
with cf.ThreadPoolExecutor(3) as ex:
    for key,rc,n in ex.map(run,jobs):
        print(key,rc,n,flush=True)
