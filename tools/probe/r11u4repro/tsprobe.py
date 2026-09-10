# r11u4 — per param_assign Rhs: owner interface, Rhs kind@span, and whether the
# Rhs object carries a DIRECT |vpiTypespec:.  Nothing inferred.
import re,sys
def show(path,tag):
    L=open(path).read().split('\n')
    ind=lambda l:len(l)-len(l.lstrip(' '))
    cur=None
    for i,l in enumerate(L):
        m=re.match(r'^(\s*)\\_interface_inst: \S+ \(([^)]*)\)',l)
        if m: cur=m.group(2)
        if re.match(r'^(\s*)\|vpiRhs:',l) and cur:
            head=L[i+1]; hb=ind(head); j=i+2; ts='no-ts'
            while j<len(L) and (L[j].strip()=='' or ind(L[j])>hb):
                if L[j].strip()!='' and ind(L[j])==hb+2 and L[j].strip()=='|vpiTypespec:': ts='HAS-TS'
                j+=1
            print('%-7s %-26s %-46s %s'%(tag,cur,head.strip()[:46],ts))
show(sys.argv[1],sys.argv[2])
