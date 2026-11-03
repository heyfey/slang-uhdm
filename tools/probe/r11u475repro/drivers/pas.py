#!/usr/bin/env python3
# pas.py <dump>: per section (allPackages/topPackages/allModules/topModules), the param_assign
# rhs constants at top level of each object: lhs name, rhs loc, decompile, value, size, consttype
import sys,re
sec=None; out=[]
lines=open(sys.argv[1]).read().split('\n')
i=0
while i<len(lines):
    l=lines[i]
    m=re.match(r'^\|(uhdm\w+):',l)
    if m: sec=m.group(1)
    if sec and re.match(r'^  \\_param_assign:',l):
        # collect block until next line with indent <=2
        j=i+1; blk=[]
        while j<len(lines) and (lines[j].startswith('    ') ):
            blk.append(lines[j]); j+=1
        rhs={}; lhs=''
        k=0
        while k<len(blk):
            b=blk[k]
            if b.startswith('    |vpiRhs:'):
                r=blk[k+1].strip(); rhs['obj']=r
                k+=2
                while k<len(blk) and blk[k].startswith('      '):
                    bb=blk[k]
                    if bb.startswith('      |') and not bb.startswith('      |vpiParent') and not bb.startswith('      |vpiTypespec'):
                        if re.match(r'      \|(vpiDecompile|vpiSize|INT|UINT|DEC|HEX|BIN|OCT|vpiConstType|vpiOpType)',bb):
                            rhs.setdefault('f',[]).append(bb.strip()[1:])
                    k+=1
                continue
            if b.startswith('    |vpiLhs:'):
                lhs=blk[k+1].strip()
            k+=1
        out.append(f"{sec:18s} {lhs:45s} {rhs.get('obj','')[:45]:45s} {' '.join(rhs.get('f',[]))}")
        i=j; continue
    i+=1
print('\n'.join(out))
