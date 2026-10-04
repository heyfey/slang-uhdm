import sys,os,subprocess,glob
import re
F=os.environ['FENCED'].split(); assert len(F)==4
SC=os.path.join(os.environ['B'],'strictcmp_x')
def lines(u):
    t=u+'.selfrec'; subprocess.run([SC,'--max','0','--dump-a',t,'--dump-b','/dev/null',u,u],capture_output=True)
    L=open(t).read().splitlines(); os.remove(t); return L
d,pat=sys.argv[1],sys.argv[2]
assert not any(re.search(r'\b'+f+r'\b',d) for f in F)
for tag,u in [('G',glob.glob(d+'/gold_*/golden.uhdm')[0])]+[(x,f'{d}/{x}.uhdm') for x in sys.argv[3:]]:
    st=[]
    for l in lines(u):
        f=l.split('\t'); dep=int(f[0])
        st=st[:dep]; st.append(f[1]+':'+(f[3] or f[2] or '')[:40])
        if pat in l and l.startswith('8\t') and l.split('\t')[1]=='ref_typespec':
            print(tag,' > '.join(st[:-1])[-260:], '|', l.split('\t')[-1][:60])
