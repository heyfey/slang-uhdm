import re,sys
# census: for each interface_inst block, report fullname, #vpiParameter, #vpiParamAssign,
# and the parameter name=value pairs / param_assign lhs names.
lines=open(sys.argv[1]).read().split('\n')
def indent(l):
    return len(l)-len(l.lstrip(' '))
out=[]
i=0
while i<len(lines):
    l=lines[i]
    m=re.match(r'^(\s*)\\_interface_inst: (\S+) \(([^)]*)\)',l)
    if m:
        base=indent(l)
        # collect block: subsequent lines with indent > base
        j=i+1
        blk=[]
        while j<len(lines):
            lj=lines[j]
            if lj.strip()=='' :
                j+=1; continue
            if indent(lj)<=base: break
            blk.append(lj); j+=1
        # count direct children markers at indent base+2
        npar=0; npa=0; pars=[]; pas=[]
        k=0
        while k<len(blk):
            lb=blk[k]
            if indent(lb)==base+2 and lb.strip()=='|vpiParameter:':
                npar+=1
                # next line is the parameter object
                if k+1<len(blk):
                    mm=re.match(r'\s*\\_parameter: \(([^)]*)\)',blk[k+1])
                    nm=None;val=None
                    # scan its subtree for vpiName and value
                    kk=k+2; sub=[]
                    ind0=indent(blk[k+1])
                    while kk<len(blk) and indent(blk[kk])>ind0:
                        sub.append(blk[kk]); kk+=1
                    for s in sub:
                        if indent(s)==ind0+2 and s.strip().startswith('|vpiName:'): nm=s.strip()[9:]
                        if indent(s)==ind0+2 and re.match(r'\|(UINT|INT|STRING|vpiDecompile):',s.strip()):
                            val=(val or '')+s.strip()+';'
                    pars.append('%s=%s'%(nm,val))
            if indent(lb)==base+2 and lb.strip()=='|vpiParamAssign:':
                npa+=1
                ind0=indent(blk[k+1]) if k+1<len(blk) else 0
                kk=k+2; sub=[]
                while kk<len(blk) and indent(blk[kk])>ind0:
                    sub.append(blk[kk]); kk+=1
                nm=None; rhs=None
                for si,s in enumerate(sub):
                    if indent(s)==ind0+2 and s.strip()=='|vpiLhs:':
                        mm2=re.match(r'\s*\\_parameter: \(([^)]*)\)',sub[si+1])
                        if mm2: nm=mm2.group(1).split('.')[-1]
                    if indent(s)==ind0+2 and s.strip()=='|vpiRhs:':
                        rhs=sub[si+1].strip().split(':')[0].replace('\\_','')
                    if rhs and indent(s)==ind0+4 and s.strip().startswith('|vpiDecompile:'):
                        rhs=rhs+'='+s.strip()[14:]
                pas.append('%s<-%s'%(nm,rhs))
            k+=1
        out.append('%-46s par=%d pa=%d | PAR[%s] | PA[%s]'%(m.group(3),npar,npa,','.join(pars),','.join(pas)))
    i+=1
for o in out: print(o)
