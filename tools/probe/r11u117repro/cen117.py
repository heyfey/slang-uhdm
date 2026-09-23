#!/usr/bin/env python3
"""cen117.py <dump> — SHAPE CENSUS of every assignment-pattern param_assign
(Rhs operation vpiOpType:75) in the package (DEF/ELAB) and module (MDEF/MELAB)
listings: section, parameter, whether the op carries a typespec ref (NAMED /
NAMELESS / none), and each operand's kind + size.  One line per param_assign,
so golden, pristine and law can be joined per cell (multiset, deduped count)."""
import sys, re
L = open(sys.argv[1], errors='replace').read().split('\n')
def ind(s): return len(s) - len(s.lstrip(' '))
sect = None; out = []
i = 0
while i < len(L):
    l = L[i]
    if l.startswith('|uhdmallPackages:'): sect = 'DEF'
    elif l.startswith('|uhdmtopPackages:'): sect = 'ELAB'
    elif l.startswith('|uhdmallModules:') or l.startswith('|uhdmallInterfaces:'): sect = 'MDEF'
    elif l.startswith('|uhdmtopModules:'): sect = 'MELAB'
    elif l.startswith('|uhdm'): sect = None
    m = re.match(r'^(\s*)\\_param_assign: ', l)
    if sect and m:
        base = len(m.group(1)); j = i + 1; blk = []
        while j < len(L) and (ind(L[j]) > base or not L[j].strip()):
            blk.append(L[j]); j += 1
        lhs = '?'; rk = None; ts = 'none'; ops = []
        for k, b in enumerate(blk):
            if b.strip() == '|vpiLhs:' and k + 1 < len(blk):
                mm = re.search(r'\(([^()]*)\)', blk[k+1]); lhs = mm.group(1) if mm else '?'
            if b.strip() == '|vpiRhs:' and k + 1 < len(blk) and rk is None:
                root = blk[k+1]; rb = ind(root); rk = root.strip().split(',')[0]
                kk = k + 2; opt = ''
                while kk < len(blk) and ind(blk[kk]) > rb:
                    s = blk[kk]
                    if ind(s) == rb + 2 and s.strip().startswith('|vpiOpType:'): opt = s.strip()[1:]
                    if ind(s) == rb + 2 and s.strip() == '|vpiTypespec:':
                        t = blk[kk+1].strip(); ts = 'NAMELESS' if re.match(r'\\_ref_typespec: *$', t) else 'NAMED'
                    if ind(s) == rb + 2 and s.strip() == '|vpiOperand:':
                        o = blk[kk+1]; ob = ind(o); sz = ''
                        q = kk + 2
                        while q < len(blk) and ind(blk[q]) > ob:
                            if ind(blk[q]) == ob + 2 and blk[q].strip().startswith('|vpiSize:'): sz = blk[q].strip()[9:]
                            q += 1
                        ops.append(o.strip().split(',')[0].lstrip('\\_').rstrip(':') + ('@' + sz if sz else ''))
                    kk += 1
                rk = rk + ' ' + opt
        if rk and 'vpiOpType:75' in rk:
            out.append('%s %s ts=%s [%s]' % (sect, lhs, ts, ' '.join(ops)))
        i = j; continue
    i += 1
print('\n'.join(sorted(set(out))))
