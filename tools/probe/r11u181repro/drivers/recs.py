#!/usr/bin/env python3
# recs.py <strict output file>...: one line per differing record: #n type name | field: A -> B (all fields that differ)
import sys
F = ['depth','type','name','defname','fullname','file','line','col','endline','endcol','decompile','size','value','consttype']
for fn in sys.argv[1:]:
    L = open(fn).read().split('\n')
    print('==', fn)
    i = 0
    while i < len(L):
        if L[i].startswith('#') and i + 2 < len(L) and L[i+1].strip().startswith('A:'):
            a = L[i+1].split('A: ',1)[1].split('\t'); b = L[i+2].split('B: ',1)[1].split('\t')
            a += ['']*(14-len(a)); b += ['']*(14-len(b))
            d = [f'{F[k]}: {a[k]!r} -> {b[k]!r}' for k in range(14) if a[k] != b[k]]
            print(f'  {L[i].split()[0]} {a[1]} {a[2]!r} [{a[6]}:{a[7]}] | ' + '; '.join(d))
            i += 3
        else:
            if L[i].startswith('fields') or L[i].startswith('objects'): print('  ', L[i])
            i += 1
