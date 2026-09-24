import sys,re,subprocess,collections
d=subprocess.run([sys.argv[1],sys.argv[2]],capture_output=True,text=True).stdout.splitlines()
c=collections.Counter()
for i,l in enumerate(d):
    m=re.match(r'^(\s*)\\_ref_typespec: \((work@[^)]*)\)$',l)
    if not m: continue
    ind=len(m.group(1)); name=m.group(2)
    for j in range(i+1,min(i+12,len(d))):
        if d[j].strip()=='|vpiActual:':
            a=d[j+1].strip(); c[(name,re.sub(r', line.*','',a))]+=1; break
for k,v in sorted(c.items()):
    if 'typespec' in k[1] and ('.g' in k[0] or 'lv' in k[0]): print(v,k[0],'->',k[1])
