import re,sys
def objs(path, kind):
    lines=open(path,errors='replace').read().split('\n')
    out=[]
    for i,l in enumerate(lines):
        m=re.match(r'^([ ]*)\\_'+kind+r': (.*)$', l)
        if not m: continue
        ind=len(m.group(1)); hdr=m.group(2)
        fields=[]
        j=i+1
        while j<len(lines):
            l2=lines[j]
            if not l2.strip(): j+=1; continue
            m2=re.match(r'^([ ]*)([|\\])', l2)
            if not m2: break
            ind2=len(m2.group(1))
            if ind2<=ind: break
            if ind2==ind+2 and m2.group(2)=='|':
                fields.append(l2.strip())
            j+=1
        out.append((hdr.strip(), fields))
    return out
path=sys.argv[1]
mode=sys.argv[2] if len(sys.argv)>2 else 'span'
for hdr,f in objs(path,'constant'):
    if any(x=='|vpiDecompile:this' for x in f):
        keys=sorted(x.split(':')[0] for x in f)
        if mode=='span': print(hdr)
        else: print(hdr,'||',','.join(keys))
