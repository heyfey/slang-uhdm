#!/usr/bin/env python3
"""r11u191: list every cont_assign Rhs constant of a uhdm-dump text (the owner line, then size / value / decompile).
usage: carhs.py <dump>"""
import sys, re
L = open(sys.argv[1]).read().split('\n')
owner = ''
for i, l in enumerate(L):
    m = re.match(r'^(\s*)\\_(module_inst|interface_inst): (.*)$', l)
    if m and len(m.group(1)) <= 4: owner = m.group(3).split(', file')[0]
    if re.match(r'^\s*\|vpiRhs:$', l) and i + 1 < len(L) and '\\_constant:' in L[i + 1]:
        ind = len(L[i + 1]) - len(L[i + 1].lstrip())
        f = []
        for k in L[i + 2:i + 40]:
            if len(k) - len(k.lstrip()) <= ind: break
            if len(k) - len(k.lstrip()) != ind + 2: continue
            if re.match(r'^\s*\|(vpiSize|vpiDecompile|UINT|INT|HEX|BIN|OCT|DEC|STRING|vpiConstType)', k): f.append(k.strip()[1:])
        print(f'{owner[:40]:40s} {L[i+1].strip()[:40]:40s} ' + ' '.join(f))
