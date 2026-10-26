#!/usr/bin/env python3
"""genca.py <dump.txt>: the elaborated gen-scope cont_assign Rhs heads of a uhdm-dump
(one line per assign: line, rhs kind + span, parent?, decompile, size, value, consttype)."""
import sys, re
L = open(sys.argv[1]).read().split('\n')
try:
    top = next(i for i, l in enumerate(L) if l.startswith('|uhdmtopModules:'))
except StopIteration:
    top = 0
i = top
while i < len(L):
    l = L[i]
    m = re.match(r'^(\s*)\\_cont_assign: , line:(\S+)', l)
    if m and i + 2 < len(L) and 'gen_scope' in L[i + 2]:
        ind = len(m.group(1))
        # find vpiRhs
        j = i + 1
        while j < len(L) and not L[j].startswith(' ' * (ind + 2) + '|vpiRhs:'):
            if re.match(r'^\s{0,%d}\S' % (ind + 1), L[j]):
                break
            j += 1
        if j < len(L) and L[j].startswith(' ' * (ind + 2) + '|vpiRhs:'):
            head = L[j + 1].strip()
            f = {}
            par = False
            k = j + 2
            while k < len(L) and L[k].startswith(' ' * (ind + 4)) and \
                    (L[k].startswith(' ' * (ind + 4) + '|') or L[k].startswith(' ' * (ind + 4) + '\\') or L[k].startswith(' ' * (ind + 5))):
                if L[k].startswith(' ' * (ind + 5)) or L[k].startswith(' ' * (ind + 4) + '\\'):
                    k += 1
                    continue
                t = L[k].strip()
                if t == '|vpiParent:':
                    par = True
                for key in ('vpiDecompile', 'vpiSize', 'vpiConstType'):
                    if t.startswith('|' + key + ':'):
                        f[key] = t.split(':', 1)[1]
                if re.match(r'^\|(UINT|INT|BIN|HEX|DEC|OCT|STRING|REAL):', t):
                    f['val'] = t[1:]
                k += 1
            print('%s | %s | par=%s | %s' % (m.group(2), head, par, ' '.join('%s=%s' % kv for kv in f.items())))
    i += 1
