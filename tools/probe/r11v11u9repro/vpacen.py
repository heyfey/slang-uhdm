import sys, re
# per param_assign: section, Lhs parameter fullname, Rhs object kind + key constant fields
def parse(path):
    lines=open(path).read().split('\n')
    sec=''; out=[]
    i=0
    cur=None
    for i,l in enumerate(lines):
        m=re.match(r'^\|uhdm(\w+):',l)
        if m: sec=m.group(1)
        if re.search(r'\\_param_assign: ',l):
            ind=len(l)-len(l.lstrip())
            # scan forward for vpiRhs / vpiLhs at ind+2
            rhs=None; lhs=None
            j=i+1
            while j<len(lines):
                lj=lines[j]
                ij=len(lj)-len(lj.lstrip())
                if ij<=ind and lj.strip().startswith('\\_'): break
                if ij==ind+2 and lj.strip()=='|vpiRhs:':
                    k=j+1
                    kind=lines[k].strip().split(':')[0].lstrip('\\_')
                    fields=[]
                    kk=k+1
                    base=len(lines[k])-len(lines[k].lstrip())
                    while kk<len(lines):
                        lk=lines[kk]; ik=len(lk)-len(lk.lstrip())
                        if ik<=base: break
                        s=lk.strip()
                        if ik==base+2 and (s.startswith('|vpiDecompile')or s.startswith('|vpiSize')or s.startswith('|vpiConstType')or re.match(r'\|(BIN|INT|UINT|DEC|HEX|STRING|REAL):',s)or s.startswith('|vpiOpType')):
                            fields.append(s)
                        kk+=1
                    rhs=(kind,' '.join(fields))
                if ij==ind+2 and lj.strip()=='|vpiLhs:':
                    lhs=lines[j+1].strip()
                j+=1
            out.append((sec,lhs,rhs))
    return out
for p in sys.argv[1:]:
    print('#####',p)
    for sec,lhs,rhs in parse(p):
        nm=re.search(r'\(([^)]*)\)',lhs or '') 
        print('  %-14s %-34s %s' % (sec,(nm.group(1) if nm else '?'), rhs))
