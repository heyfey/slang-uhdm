#!/usr/bin/env python3
# v11u59 SHAPE LISTER + cell reader for the ELABORATED package listing.
# Reads a uhdm-dump, restricts to the uhdmtopPackages section, and for every
# tagged_pattern prints  <member> size=<vpiSize> ct=<vpiConstType> dec=<decompile> val=<value>
# plus a SHAPE line per pattern operation (TAGGED n=<operands> / FLAT).
import sys, re
path = sys.argv[1]
lines = open(path, errors='replace').read().split('\n')
start = next((i for i,l in enumerate(lines) if l.startswith('|uhdmtopPackages')), 0)
seg = lines[start:]
cells = []
i = 0
while i < len(seg):
    l = seg[i]
    if '\\_tagged_pattern:' in l:
        ind = len(l) - len(l.lstrip())
        blk = [l]
        j = i+1
        while j < len(seg):
            s = seg[j]
            if s.strip() and (len(s) - len(s.lstrip())) <= ind and '\\_tagged_pattern' in s:
                break
            if s.strip() and (len(s) - len(s.lstrip())) < ind:
                break
            blk.append(s); j += 1
        txt = '\n'.join(blk)
        m = re.search(r'string_typespec: \((\w+)\)', txt)
        member = m.group(1) if m else '?'
        kind = 'constant' if re.search(r'\|vpiPattern:\n\s*\\_constant:', txt) else \
               ('operation' if re.search(r'\|vpiPattern:\n\s*\\_operation:', txt) else 'other')
        # first constant under vpiPattern
        pm = re.search(r'\|vpiPattern:\n(\s*)\\_(\w+):[^\n]*\n((?:\1 .*\n|\1\t.*\n)*)', txt)
        body = pm.group(3) if pm else ''
        d = re.search(r'\|vpiDecompile:(.*)', body)
        z = re.search(r'\|vpiSize:(\d+)', body)
        c = re.search(r'\|vpiConstType:(\d+)', body)
        v = re.search(r'\|((?:UINT|INT|HEX|BIN|DEC|OCT|REAL|STRING|SCALAR):[^\n]*)', body)
        cells.append((member, kind, z.group(1) if z else '-', c.group(1) if c else '-',
                      d.group(1) if d else '-', v.group(1) if v else '-'))
        i = j
        continue
    i += 1
print('SHAPE tagged_patterns=%d' % len(cells))
for (mem, kind, z, c, d, v) in cells:
    print('CELL %-6s %-9s size=%-4s ct=%-3s dec=%-16s val=%s' % (mem, kind, z, c, d, v))
