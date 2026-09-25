#!/usr/bin/env python3
"""shape.py <prefix>...: classify every differing record of <prefix>.strict (run with a large --max) whose
object is a hier_path or sits under one: view (def = under gen_if/gen_if_else/gen_for/gen_case/gen_region,
elab = under gen_scope, none), the path's own container (the first non-expression ancestor above the
hier_path: cont_assign, range, gen_if..., port, assignment ...), field, element role (path, base, mid, leaf).
Prints one tally line per (row, view, container, role, field) and the total.  Reads only named files."""
import re, sys, collections
GEN_DEF = {'gen_if', 'gen_if_else', 'gen_for', 'gen_case', 'gen_region'}
EXPR = {'operation', 'hier_path', 'ref_obj', 'bit_select', 'part_select', 'indexed_part_select', 'var_select',
        'constant', 'sys_func_call', 'func_call'}
def load(f):
    R = []
    for l in open(f, errors='replace'):
        l = l.rstrip('\n')
        if re.match(r'^\d+\t', l) or not R: R.append(l.split('\t'))
        else: R[-1][-1] += '\\n' + l
    return R
def anc(R, i):
    out = []; d = int(R[i][0]); j = i - 1
    while j >= 0 and d > 0:
        if int(R[j][0]) < d: out.append(j); d = int(R[j][0])
        j -= 1
    return out
tot = collections.Counter()
for p in sys.argv[1:]:
    A = load(p + '.ra'); row = p.split('/')[-1]
    for l in open(p + '.strict'):
        m = re.match(r'#(\d+) (\S+)', l)
        if not m: continue
        i = int(m.group(1)); f = m.group(2)
        if i >= len(A): continue
        a = anc(A, i); t = A[i][1]
        hp = i if t == 'hier_path' else next((j for j in a[:2] if A[j][1] == 'hier_path'), None)
        if hp is None: continue
        role = 'path' if hp == i else None
        if role is None:
            sib = []; hd = int(A[hp][0]); k = hp + 1
            while k < len(A) and int(A[k][0]) > hd:
                if int(A[k][0]) == hd + 1: sib.append(k)
                k += 1
            role = 'base' if sib and sib[0] == i else 'leaf' if sib and sib[-1] == i else 'mid' if i in sib else 'sub'
        ha = anc(A, hp)
        ctr = next((A[j][1] for j in ha if A[j][1] not in EXPR), '?')
        view = 'def' if any(A[j][1] in GEN_DEF for j in ha) else 'elab' if any(A[j][1] == 'gen_scope' for j in ha) else 'none'
        tot[(row, view, ctr, role, f)] += 1
for k, v in sorted(tot.items()): print(v, *k, sep='\t')
print('TOTAL', sum(tot.values()), sep='\t')
