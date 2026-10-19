import csv,os,re,subprocess,sys
from concurrent.futures import ThreadPoolExecutor
CMP='/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp'
work=sys.argv[1]; rows=[l.strip() for l in open(sys.argv[2]) if l.strip()]
def one(rel):
    d=os.path.join(work,rel[:-3]); o=os.path.join(d,'slang.uhdm')
    try: c=open(os.path.join(d,'cmds.txt')).read()
    except: return rel,'nocmds','',''
    m=re.search(r'cache hit (.*)\)',c); g=os.path.join(m.group(1),'golden.uhdm') if m else os.path.join(d,'slpp_all','surelog.uhdm')
    if not os.path.exists(o): return rel,'noslang','',''
    p=subprocess.run([CMP,g,o],capture_output=True,text=True,timeout=600)
    L=(p.stderr+p.stdout).splitlines()
    def grab(tag):
        for i,l in enumerate(L):
            if l.startswith(tag):
                f=L[i+1] if i+1<len(L) else ''
                f2=L[i+2] if i+2<len(L) else ''
                return (f+' | '+f2)
        return ''
    return rel,str(len(L)),re.sub(r'id:\d+,? ?','',grab('LHS')),re.sub(r'id:\d+,? ?','',grab('RHS'))
with ThreadPoolExecutor(6) as ex:
    w=csv.writer(sys.stdout)
    for r in ex.map(one,rows): w.writerow(r)
