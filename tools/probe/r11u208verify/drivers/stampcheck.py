#!/usr/bin/env python3
# (r11u208) stampcheck.py <dump>...: for every user call `f(...)` in a uhdm-dump (the weakly-referenced tail cut), whether
# its first reference argument carries a vpiTypespec (the formal-typespec stamp of the evaluator), keyed by the call's
# line and the dump indentation (the listing it sits in); prints one line per dump: line@indent=S (stamped) / b (bare).
import sys, re
def calls(p):
    L = open(p, errors='replace').read().split('\\_weaklyReferenced')[0].splitlines(); out = []
    for i, l in enumerate(L):
        m = re.search(r'\\_func_call: \(f\), line:(\d+):(\d+)', l)
        if not m: continue
        ind = len(l) - len(l.lstrip())
        if i > 0 and L[i-1].strip() in ('|vpiParent:',): continue   # a back-reference line
        stamp = None
        for j in range(i + 1, min(i + 40, len(L))):
            lj = L[j]; indj = len(lj) - len(lj.lstrip())
            if indj <= ind: break
            if re.search(r'\\_(ref_obj|indexed_part_select|part_select|bit_select): ', lj) and L[j-1].strip() == '|vpiArgument:':
                stamp = False
                for k in range(j + 1, min(j + 14, len(L))):
                    if len(L[k]) - len(L[k].lstrip()) <= indj: break
                    if L[k].strip() == '|vpiTypespec:': stamp = True
                break
        if stamp is not None: out.append(f'{m.group(1)}:{m.group(2)}@{ind}=' + ('S' if stamp else 'b'))
    return out
for p in sys.argv[1:]: print(p.split('/')[-1], ' '.join(calls(p)))
