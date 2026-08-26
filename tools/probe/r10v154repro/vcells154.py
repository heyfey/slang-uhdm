#!/usr/bin/env python3
"""Extract enum_const cells from a uhdm-dump text.  Key = (owner, name, span);
both views kept under one key as a MULTISET (RESUME.md §9)."""
import sys, re, collections
def cells(path):
    out = collections.Counter()
    lines = open(path, errors='replace').read().split('\n')
    i = 0
    n = len(lines)
    while i < n:
        m = re.search(r'\\_enum_const: \((.*?)\), line:(\d+):(\d+), endln:(\d+):(\d+)', lines[i])
        if not m:
            i += 1; continue
        name, l, c, el, ec = m.groups()
        owner=''; val=''; dec='<none>'; size='<none>'
        j = i+1
        while j < n and j < i+14:
            s = lines[j]
            if re.search(r'\\_enum_const:', s): break
            mo = re.search(r'\\_enum_typespec: \((.*?)\)', s)
            if mo and not owner: owner = mo.group(1)
            mv = re.match(r'\s*\|(INT|UINT|BIN|HEX|OCT|DEC|STRING|REAL|SCAL):(.*)$', s)
            if mv: val = mv.group(1)+':'+mv.group(2)
            md = re.match(r'\s*\|vpiDecompile:(.*)$', s)
            if md: dec = md.group(1)
            ms = re.match(r'\s*\|vpiSize:(-?\d+)$', s)
            if ms: size = ms.group(1)
            j += 1
        if owner:
            out[(owner, name, f'{l}:{c}-{el}:{ec}', val, dec, size)] += 1
        i += 1
    return out
if __name__ == '__main__':
    for k, v in sorted(cells(sys.argv[1]).items()):
        print('\t'.join(list(k)+[str(v)]))
