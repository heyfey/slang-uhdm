#!/usr/bin/env python3
# r11u419 pvscan.py <dump>: predict the three port-view laws on a pristine database's uhdm-dump.
# A port view = an interface_inst listed under vpiInterface with vpiParamAssign entries and no
# vpiParameter entries of its own.  Prints one line per predicted firing:
#   A <view> <lhs>      a port-view Rhs constant of const type 7 written UINT: (ifPortViewArithIntForm419)
#   B <view> <lhs>      a Lhs name taken by an earlier param_assign of the view (ifPortViewPaLhsOwn419)
#   C <view> <alias>    a typedef alias named <view>.<param>.<alias> under a def-named Lhs (ifPortViewTdAliasDefName419)
import sys, re
lines = open(sys.argv[1], errors='replace').read().split('\n')
def ind(l): return len(l) - len(l.lstrip(' '))
i = 0; n = len(lines); cands = set()
while i < n:
    l = lines[i]
    if l.lstrip().startswith('|vpiInterface:') and i + 1 < n and lines[i+1].lstrip().startswith('\\_interface_inst:'):
        h = lines[i+1]; hi = ind(h)
        m = re.search(r'\((work@[^)]*)\)', h); view = m.group(1) if m else '?'
        j = i + 2; blk = []
        while j < n and (ind(lines[j]) > hi or lines[j].strip() == ''):
            blk.append(lines[j]); j += 1
        own = hi + 2
        hasP = any(ind(b) == own and b.strip() == '|vpiParameter:' for b in blk)
        pas = [k for k, b in enumerate(blk) if ind(b) == own and b.strip() == '|vpiParamAssign:']
        if pas and not hasP:
            seen = set()
            for k in pas:
                # the param_assign's own lines up to the next sibling at `own`
                e = k + 1
                while e < len(blk) and not (ind(blk[e]) == own and blk[e].strip().startswith('|')) :
                    e += 1
                sub = blk[k+1:e]
                lhs = None; rhsU = False; rhsT = None
                for q, s in enumerate(sub):
                    st = s.strip()
                    if st == '|vpiLhs:' and q + 1 < len(sub):
                        mm = re.search(r'\\_parameter: \(([^)]*)\)', sub[q+1]); lhs = mm.group(1) if mm else None
                    if st == '|vpiRhs:' and q + 1 < len(sub) and '\\_constant:' in sub[q+1]:
                        ci = ind(sub[q+1]) + 2; vals = []
                        for s2 in sub[q+2:]:
                            if ind(s2) < ci: break
                            if ind(s2) == ci: vals.append(s2.strip())
                        if any(v.startswith('|UINT:') for v in vals) and '|vpiConstType:7' in vals: rhsU = True
                if lhs:
                    nm = lhs.split('.')[-1]
                    if rhsU: print('A', view, nm)
                    if nm in seen: print('B', view, nm)
                    seen.add(nm)
                    if lhs != view + '.' + nm:
                        cands.add(view + '.' + nm + '.')
        i = j
    else:
        i += 1
# C: a vpiFullName anywhere in the database naming <view>.<param>.<alias> for a def-named Lhs
if cands:
    found = set()
    for l in lines:
        s = l.strip()
        if s.startswith('|vpiFullName:'):
            fn = s[len('|vpiFullName:'):]
            for c in cands:
                if fn.startswith(c) and '.' not in fn[len(c):]:
                    found.add(fn)
    for f in sorted(found):
        print('C', f.rsplit('.', 2)[0], f)
