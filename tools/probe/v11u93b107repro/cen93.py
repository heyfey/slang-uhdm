#!/usr/bin/env python3
# v11u93 golden-shape census over one uhdm-dump (stdin). Prints counts:
#  C1 = packed_array_typespec whose elem ref is UNNAMED and actual is an UNNAMED struct/union_typespec
#  C2 = type_parameter whose typespec actual is an UNNAMED struct/union_typespec
#  C3 = elem ref_typespec NAMED under a packed_array_typespec (the § 31 named-element shape)
#  C3D = C3 where the ref fullname has exactly 3 dot-free components (definition-level: work@def.param.elem)
import sys, re
L = sys.stdin.read().split('\n')
c1 = c2 = c3 = c3d = 0
UN = re.compile(r'^\s*\\_(struct|union)_typespec: ,')
for i, ln in enumerate(L):
    s = ln.strip()
    if s == '|vpiElemTypespec:' and i + 1 < len(L):
        ref = L[i + 1].strip()
        # find actual within the ref block
        act = None
        for j in range(i + 2, min(i + 12, len(L))):
            if L[j].strip() == '|vpiActual:' and j + 1 < len(L):
                act = L[j + 1]; break
        if re.match(r'^\\_ref_typespec:\s*$', ref):
            if act and UN.match(act): c1 += 1
        m = re.match(r'^\\_ref_typespec: \((.+)\)$', ref)
        if m:
            c3 += 1
            fn = m.group(1)
            if fn.startswith('work@') and fn.count('.') == 2: c3d += 1
    if re.match(r'^\\_type_parameter: ', s) and not ln.startswith(' ' * 6):
        # own block: look for |vpiTypespec: then |vpiActual:
        ind = len(ln) - len(ln.lstrip())
        for j in range(i + 1, min(i + 20, len(L))):
            lj = L[j]
            if lj.strip() and (len(lj) - len(lj.lstrip())) <= ind and not lj.strip().startswith('|'):
                break
            if lj.strip() == '|vpiActual:' and j + 1 < len(L):
                if UN.match(L[j + 1]): c2 += 1
                break
print(c1, c2, c3, c3d)
