import re,sys
NETK={'logic_var','logic_net','array_var','array_net','struct_var','struct_net',
      'int_var','bit_var','enum_var','packed_array_var','packed_array_net','integer_var'}
VAL=r'(?:UINT|INT|REAL|STRING|BIN|HEX|OCT|SCAL|DEC)'
def census(path):
    lines=open(path).read().split('\n')
    out=[]
    for i,l in enumerate(lines):
        m=re.match(r'^(\s*)\\_interface_inst: (\S+) \(([^)]*)\)',l)
        if not m: continue
        ind=len(m.group(1)); name=m.group(3)
        pars=[];pas=[];nets=[]
        j=i+1
        while j<len(lines):
            l2=lines[j]
            if l2.strip()=='':
                j+=1; continue
            ind2=len(l2)-len(l2.lstrip())
            if ind2<=ind: break
            if ind2==ind+2:
                mm2=re.match(r'^\s*\\_(\w+): (.*)$',l2)
                if mm2:
                    kind=mm2.group(1)
                    k=j+1; blk=[]
                    while k<len(lines):
                        l3=lines[k]
                        if l3.strip()=='': k+=1; continue
                        i3=len(l3)-len(l3.lstrip())
                        if i3<=ind+2: break
                        blk.append(l3); k+=1
                    b='\n'.join(blk)
                    if kind=='parameter':
                        pn=re.search(r'\|vpiName:(\S+)',b)
                        pv=re.search(r'^[ \t]*\|('+VAL+r':\S*)',b,re.M)
                        pars.append((pn.group(1) if pn else '?', pv.group(1) if pv else '-'))
                    elif kind=='param_assign':
                        ov='1' if re.search(r'^[ \t]*\|vpiOverriden:1',b,re.M) else '0'
                        lhs=re.search(r'\|vpiLhs:\n[ \t]*\\_parameter: \(([^)]*)\)',b)
                        rhs=re.search(r'\|vpiRhs:\n[ \t]*\\_(\w+):',b)
                        rv='-'
                        for _i,_l in enumerate(blk):
                            if _l.strip()=='|vpiRhs:':
                                for _m in blk[_i+1:_i+14]:
                                    _r=re.match(r'[ \t]*\|('+VAL+r':\S*)',_m)
                                    if _r: rv=_r.group(1); break
                                break
                        ln=lhs.group(1).split('.')[-1] if lhs else '?'
                        pas.append((ln, rhs.group(1) if rhs else '?', rv, ov))
                    elif kind in NETK:
                        nn=re.search(r'\|vpiName:(\S+)',b)
                        sz=re.search(r'\|vpiSize:(\d+)',b)
                        nets.append((kind,nn.group(1) if nn else '?', sz.group(1) if sz else '-'))
            j+=1
        out.append((name,pars,pas,nets))
    best={}
    for name,pars,pas,nets in out:
        sc=len(pars)+len(pas)+len(nets)
        if name not in best or sc>best[name][0]:
            best[name]=(sc,pars,pas,nets)
    return best
b=census(sys.argv[1])
for k in sorted(b):
    s,pars,pas,nets=b[k]
    print("%s par=%d pa=%d nets=%d"%(k,len(pars),len(pas),len(nets)))
    for p in pars: print("    P %s %s"%(p[0],p[1]))
    for p in pas: print("    A %s rhs=%s %s ov=%s"%(p[0],p[1],p[2],p[3]))
    for n in sorted(nets): print("    N %s %s size=%s"%(n[0],n[1],n[2]))
