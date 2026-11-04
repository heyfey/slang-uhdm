import sys,re
# print, for instance work@top.u, A param value, A pa rhs (size,val,ts), B pa rhs (size,val)
def blocks(lines):
    out=[];i=0
    while i<len(lines):
        if lines[i].strip().startswith('\\_param_assign:'):
            ind=len(lines[i])-len(lines[i].lstrip()); j=i+1
            while j<len(lines) and (len(lines[j])-len(lines[j].lstrip())>ind): j+=1
            out.append(lines[i:j]); i=j
        else: i+=1
    return out
L=open(sys.argv[1]).read().split('\n')
res={}
for b in blocks(L):
    txt='\n'.join(b)
    m=re.search(r'vpiLhs:\n\s*\\_parameter: \((work@[^)]*)\)',txt)
    if not m: continue
    nm=m.group(1)
    if not nm.startswith('work@top.u.'): continue
    rhs=txt.split('vpiLhs:')[0]
    sz=re.search(r'vpiSize:(-?\d+)',rhs); val=re.search(r'\|((?:U?INT|DEC|HEX|BIN|OCT|REAL|STRING):[^\n]*)',rhs)
    ts=re.search(r'vpiActual:\n\s*\\_(\w+)',rhs)
    res[nm.split('.')[-1]]=f"{sz.group(1) if sz else '?'}/{val.group(1) if val else '?'}{'/'+ts.group(1) if ts else ''}"
pv=''
for i,l in enumerate(L):
    if '\\_parameter: (work@top.u.A)' in l and i+3<len(L) and 'vpiParent' in L[i+1]:
        for k in range(i+1,i+6):
            mm=re.search(r'\|((?:U?INT|DEC|HEX|BIN|OCT):\S*)',L[k])
            if mm: pv=mm.group(1);break
        break
print(f"Aval={pv} A={res.get('A')} B={res.get('B')}")
