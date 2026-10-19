# Predict r11u407 law firings from pristine databases (uhdm-dump text).
import subprocess,sys,os,re
from concurrent.futures import ThreadPoolExecutor
DUMP='/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump'
dbs=[l.strip() for l in open(sys.argv[1]) if l.strip()]
out=open(sys.argv[2],'w')
node=re.compile(r'^(\s*)\\_(\w+):')
def scan(db):
    try: txt=subprocess.run([DUMP,db],capture_output=True,text=True,timeout=1800).stdout
    except Exception as e: return [(db,'ERR',str(e))]
    hits=[]; sec=None; stack=[]; lines=txt.splitlines()
    for i,l in enumerate(lines):
        if l.startswith('|uhdm'): sec=l; stack=[]; continue
        m=node.match(l)
        if not m: continue
        ind=len(m.group(1)); typ=m.group(2)
        while stack and stack[-1][0]>=ind: stack.pop()
        prev=lines[i-1].strip() if i else ''
        stack.append((ind,typ,prev))
        types=[s[1] for s in stack]
        if sec and 'topPackages' in sec:
            # enum const actual under return_stmt through operations only
            if typ=='enum_const' and prev=='|vpiActual:' and len(stack)>=3 and stack[-2][1]=='ref_obj':
                anc=types[:-2]
                if 'return_stmt' in anc:
                    k=len(anc)-1-anc[::-1].index('return_stmt')
                    mid=anc[k+1:]
                    if mid and all(t=='operation' for t in mid): hits.append((db,'RETENUM',l.strip()))
            if typ=='constant' and prev=='|vpiActual:' and len(stack)>=4 and stack[-2][1]=='ref_obj' and stack[-3][1]=='bit_select' and stack[-2][2]=='|vpiIndex:':
                anc=types[:-3]
                if 'return_stmt' in anc:
                    k=len(anc)-1-anc[::-1].index('return_stmt')
                    mid=anc[k+1:]
                    if all(t=='operation' for t in mid): hits.append((db,'RETBS',lines[i-2].strip()))
        if typ=='event_control':
            pass
    return hits
with ThreadPoolExecutor(int(sys.argv[3]) if len(sys.argv)>3 else 3) as ex:
    for hs in ex.map(scan,dbs):
        for h in hs: out.write('\t'.join(h)+'\n'); out.flush()
