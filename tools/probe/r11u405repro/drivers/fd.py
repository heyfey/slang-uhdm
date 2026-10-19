import csv,os,re,subprocess,sys
from concurrent.futures import ThreadPoolExecutor
work=sys.argv[1]; rows=[l.strip() for l in open(sys.argv[2]) if l.strip()]
def gold(d):
    c=open(os.path.join(d,'cmds.txt')).read(); m=re.search(r'cache hit (.*)\)',c)
    return os.path.join(m.group(1),'golden.uhdm') if m else os.path.join(d,'slpp_all','surelog.uhdm')
def one(rel):
    d=os.path.join(work,rel[:-3]); o=os.path.join(d,'slang.uhdm')
    if not os.path.exists(o): return rel,'-1','noslang'
    p=subprocess.run(['/tmp/r11u405_scr/ddiff.sh',gold(d),o],capture_output=True,text=True,timeout=900)
    L=p.stdout.splitlines()
    ch=[l for l in L if l[:1] in '<>']
    return rel,str(len(ch)),' ## '.join(L[:7])
with ThreadPoolExecutor(6) as ex:
    w=csv.writer(sys.stdout)
    for r in ex.map(one,rows): w.writerow(r)
