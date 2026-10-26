#!/usr/bin/env python3
"""gcscan.py <dump.txt>: the § genCaConstRhsWhole433 candidates of a uhdm-dump, in the
elaborated tree (after |uhdmtopModules:): a gen_scope cont_assign whose Rhs is
(A) an operation whose every leaf is a constant, (B) a located constant with no
parent, (C) a $bits / $size / $clog2 sys_func_call.  One line per candidate."""
import sys, re
L = open(sys.argv[1], errors='replace').read().split('\n')
try:
    top = next(i for i, l in enumerate(L) if l.startswith('|uhdmtopModules:'))
except StopIteration:
    sys.exit(0)
def block(i, ind):
    j = i + 1
    while j < len(L) and (len(L[j]) - len(L[j].lstrip(' '))) > ind:
        j += 1
    return L[i:j]
for i in range(top, len(L)):
    m = re.match(r'^(\s*)\\_cont_assign: , line:(\S+)', L[i])
    if not m or i + 2 >= len(L) or 'gen_scope' not in L[i + 2]:
        continue
    ind = len(m.group(1))
    j = i + 1
    while j < len(L) and (len(L[j]) - len(L[j].lstrip(' '))) > ind:
        if L[j] == ' ' * (ind + 2) + '|vpiRhs:':
            break
        j += 1
    if j >= len(L) or L[j] != ' ' * (ind + 2) + '|vpiRhs:':
        continue
    head = L[j + 1]
    hind = len(head) - len(head.lstrip(' '))
    b = block(j + 1, hind)
    kinds = set()
    for l in b[1:]:
        mm = re.match(r'^\s*\\_(\w+):', l)
        if mm and not l.strip().startswith('\\_cont_assign') :
            kinds.add(mm.group(1))
    h = head.strip()
    tag = None
    if h.startswith('\\_operation'):
        # leaves: anything that is not operation/constant/ref_typespec/typespec kinds under the subtree
        bad = [k for k in kinds if k not in ('operation', 'constant', 'ref_typespec', 'int_typespec', 'logic_typespec', 'bit_typespec', 'range') and not k.endswith('typespec')]
        if not bad:
            tag = 'A'
    elif h.startswith('\\_constant: , line'):
        if '|vpiParent:' not in [x.strip() for x in b[1:3]]:
            tag = 'B'
    elif h.startswith('\\_sys_func_call: ($bits)') or h.startswith('\\_sys_func_call: ($size)') or h.startswith('\\_sys_func_call: ($clog2)'):
        tag = 'C'
    if tag:
        print('%s %s %s' % (tag, m.group(2), h[:80]))
