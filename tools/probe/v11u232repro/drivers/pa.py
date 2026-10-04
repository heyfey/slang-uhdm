import sys,re,subprocess,os
# pa.py <uhdm> : elaborated param_assign Rhs facts (inst, param, decompile, size, value, typespec loc)
dump=os.environ['UHDM_DUMP']
assert os.access(dump,os.X_OK)
fence=os.environ['FENCE_RE']; assert fence
assert not re.search(fence, sys.argv[1])
txt=subprocess.run([dump,sys.argv[1]],capture_output=True,text=True).stdout.splitlines()
out=[]
i=0
while i<len(txt):
    l=txt[i]
    m=re.match(r'(\s*)\\_param_assign:',l)
    if m and i+1<len(txt):
        ind=len(m.group(1))
        inst=next((re.search(r'_module_inst: \S+ \((work@[^)]*)\)',x) for x in txt[i+1:i+4] if re.search(r'_module_inst: \S+ \((work@[^)]*)\)',x)),None)
        if inst and '.' in inst.group(1):
            blk=[];j=i+2
            while j<len(txt) and (len(txt[j])-len(txt[j].lstrip()))>ind: blk.append(txt[j]);j+=1
            # rhs = first child line at ind+2
            par=next((re.search(r'\(([^)]*)\)',b).group(1) for b in blk if '\\_parameter:' in b or '\\_type_parameter' in b),'?')
            dec=next((b.strip() for b in blk if 'vpiDecompile' in b),'')
            sz=next((b.strip() for b in blk if 'vpiSize' in b),'')
            val=next((b.strip() for b in blk if re.match(r'\s*\|(UINT|INT|HEX|BIN|OCT|DEC|STRING|REAL|SCAL):',b)),'')
            ts=next((b.strip() for b in blk if re.search(r'\\_(?!ref_)\w+_typespec',b)),'')
            out.append(f"{inst.group(1)} {par} | {dec} {sz} {val} | {ts}")
            i=j;continue
    i+=1
print('\n'.join(sorted(set(out))))
