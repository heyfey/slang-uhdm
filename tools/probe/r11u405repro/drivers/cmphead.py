import csv,os,re,subprocess,sys
from concurrent.futures import ThreadPoolExecutor
CMP='/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp'
work=sys.argv[1]; rows=[l.strip() for l in open(sys.argv[2]) if l.strip()]
st={}
if len(sys.argv)>3:
    for r in csv.DictReader(open(sys.argv[3])): st[r['path']]=r['agreement']+' '+r['strict']
def one(rel):
    d=os.path.join(work,rel[:-3]); o=os.path.join(d,'slang.uhdm')
    try: c=open(os.path.join(d,'cmds.txt')).read()
    except: return rel,'nocmds'
    m=re.search(r'cache hit (.*)\)',c); g=os.path.join(m.group(1),'golden.uhdm') if m else os.path.join(d,'slpp_all','surelog.uhdm')
    if not os.path.exists(o): return rel,'noslang'
    p=subprocess.run([CMP,g,o],capture_output=True,text=True,timeout=600)
    L=[l for l in (p.stderr+p.stdout).splitlines()]
    out=[]
    for i,l in enumerate(L):
        if l.startswith('LHS') or l.startswith('RHS'):
            out.append(l[:3]+': '+' | '.join(x.strip() for x in L[i+1:i+3]))
    return rel,' || '.join(out)[:400]
with ThreadPoolExecutor(6) as ex:
    for rel,h in ex.map(one,rows):
        if st.get(rel,'').startswith('IDENTICAL'): continue
        print(rel.replace('generated/basejump/','').replace('generated/',''),'::',st.get(rel,''),'::',re.sub(r'id:\d+, ','',h))
