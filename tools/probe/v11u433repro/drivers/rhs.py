import sys,re
# rhs.py dumpfile : print each cont_assign Rhs (header + up to 6 fields) under a gen_scope parent
L=open(sys.argv[1]).read().split('\n')
i=0;out=[]
while i<len(L):
    if L[i].startswith('\\_cont_assign: ') and i+2<len(L) and L[i+1]=='|vpiParent:' and L[i+2].startswith('\\_gen_scope'):
        hdr=L[i]
        j=i
        while j<len(L) and L[j]!='|vpiRhs:': j+=1
        k=j+1; seg=[L[k]]; k+=1
        while k<len(L) and not L[k].startswith('|vpiLhs') and len(seg)<14:
            if L[k] in ('|vpiParent:',): seg.append('P:'+L[k+1][:40]); k+=2; continue
            if L[k].startswith('|vpiDecompile') or L[k].startswith('|vpiSize') or L[k].startswith('|UINT') or L[k].startswith('|INT') or L[k].startswith('|BIN') or L[k].startswith('|vpiName'):
                seg.append(L[k])
            k+=1
        out.append(hdr.split(',')[1].strip()+' => '+' '.join(seg))
        i=k
    else: i+=1
print('\n'.join(out))
