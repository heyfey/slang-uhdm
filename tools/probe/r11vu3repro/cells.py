import re,sys,subprocess
DUMP='/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump'
def cells(path):
    out=subprocess.run([DUMP,path],capture_output=True,text=True).stdout
    lines=out.split('\n')
    # only the ELAB section (after uhdmtopModules:)
    try:
        i=next(k for k,l in enumerate(lines) if 'uhdmtopModules:' in l)
        lines=lines[i:]
    except StopIteration:
        pass
    res={}
    cur_mod=None
    for k,l in enumerate(lines):
        m=re.match(r'^(\s*)\\_module_inst: ([^,]*), file',l)
        if m: cur_mod=m.group(2).strip()
        if l.strip()=='|vpiParamAssign:':
            ind=len(l)-len(l.lstrip())
            # scan forward within this param_assign block
            name=None;dec=None;ct=None;sz=None;const=False
            for j in range(k+1,min(k+60,len(lines))):
                lj=lines[j]
                if lj.strip().startswith('|vpi') and (len(lj)-len(lj.lstrip()))<=ind and j>k+1:
                    break
                s=lj.strip()
                if s.startswith('\\_parameter:') and name is None:
                    name=s.split(':',1)[1].strip()
                if s.startswith('\\_constant:'): const=True
                if s.startswith('|vpiDecompile:') and dec is None: dec=s.split(':',1)[1]
                if s.startswith('|vpiConstType:') and ct is None: ct=s.split(':',1)[1]
                if s.startswith('|vpiSize:') and sz is None: sz=s.split(':',1)[1]
            res.setdefault((cur_mod,name),[]).append((ct,sz,dec,const))
    return res
a=cells(sys.argv[1]); b=cells(sys.argv[2]) if len(sys.argv)>2 else None
keys=sorted(set(a)|set(b or {}),key=lambda x:(str(x[0]),str(x[1])))
for k in keys:
    va=a.get(k); vb=(b or {}).get(k)
    flag='' if va==vb else '   <<< DIFF'
    if b is None: print(k,va)
    else: print(k,'G=',va,'O=',vb,flag)
