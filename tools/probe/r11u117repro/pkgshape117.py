#!/usr/bin/env python3
"""pkgshape117.py <dump> [param] — SHAPE LISTER: for each package listing
(uhdmallPackages = def view, uhdmtopPackages = elab view) print the param_assign
Rhs of the named parameter (default IMPL): its kind, whether it carries a
vpiTypespec (and that ref's name / actual), and each operand's kind, size,
decompile and value.  Keyed by listing + parameter name + operand index, so a
nameless, parentless ref_typespec is still a visible cell."""
import sys, re
path = sys.argv[1]; want = sys.argv[2] if len(sys.argv) > 2 else 'IMPL'
L = open(path, errors='replace').read().split('\n')
def ind(s): return len(s) - len(s.lstrip(' '))
out = []
sect = None
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
        base = len(m.group(1))
        j = i + 1; blk = []
        while j < len(L) and (ind(L[j]) > base or L[j].strip() == ''):
            blk.append(L[j]); j += 1
        # lhs name
        lhs = ''
        for k, b in enumerate(blk):
            if b.strip() == '|vpiLhs:' and k + 1 < len(blk):
                mm = re.search(r'\(([^()]*)\)', blk[k+1]); lhs = re.split(r'::|\.', mm.group(1))[-1] if mm else blk[k+1].strip()
        if lhs == want:
            # rhs root
            for k, b in enumerate(blk):
                if b.strip() == '|vpiRhs:':
                    root = blk[k+1]; rb = ind(root)
                    rk = root.strip().split(':')[0].lstrip('\\_')
                    # rhs direct fields (indent rb+2)
                    ts = '-'; ops = []
                    kk = k + 2
                    while kk < len(blk) and ind(blk[kk]) > rb:
                        s = blk[kk]
                        if ind(s) == rb + 2 and s.strip() == '|vpiTypespec:':
                            t = blk[kk+1].strip(); act = ''
                            q = kk + 2
                            while q < len(blk) and ind(blk[q]) > ind(blk[kk+1]):
                                if blk[q].strip() == '|vpiActual:': act = blk[q+1].strip(); break
                                q += 1
                            ts = t + ' -> ' + act
                        if ind(s) == rb + 2 and s.strip() == '|vpiOperand:':
                            o = blk[kk+1]; ob = ind(o); props = []
                            q = kk + 2
                            while q < len(blk) and ind(blk[q]) > ob:
                                if ind(blk[q]) == ob + 2 and re.match(r'\|(vpiSize|vpiDecompile|BIN|HEX|DEC|UINT|INT|vpiConstType|vpiOpType):', blk[q].strip()):
                                    props.append(blk[q].strip()[1:])
                                q += 1
                            ops.append(o.strip().split(',')[0].lstrip('\\_') + ' ' + ' '.join(props))
                        if ind(s) == rb + 2 and re.match(r'\|vpiOpType:', s.strip()):
                            rk += ' ' + s.strip()[1:]
                        kk += 1
                    out.append('%s %s RHS=%s TS=%s' % (sect, lhs, rk, ts))
                    for n, o in enumerate(ops): out.append('%s %s  op%d %s' % (sect, lhs, n, o))
        i = j; continue
    i += 1
print('\n'.join(out) if out else 'NONE')
