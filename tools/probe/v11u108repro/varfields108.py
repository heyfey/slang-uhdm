#!/usr/bin/env python3
"""varfields108.py <dump> : for every *_var / *_net object block DEFINED in the dump
(header line followed by its own '|field' lines), print
  <section> <kind> <fullname> <sorted direct field names, with scalar values>
section = DEF (before |uhdmtopModules:) or ELAB.  Nested object headers are
followed only to learn which fields exist (vpiAttribute, vpiTypespec, ...)."""
import re, sys
sec = 'DEF'
out = []
lines = open(sys.argv[1], errors='replace').read().splitlines()
hdr = re.compile(r'^( *)\\_([a-z_]+(?:_var|_net)): \(([^)]*)\)')
i = 0
while i < len(lines):
    l = lines[i]
    if l.startswith('|uhdmtopModules:'): sec = 'ELAB'
    m = hdr.match(l)
    if m and i + 1 < len(lines) and lines[i+1].startswith(m.group(1) + '  |'):
        ind = m.group(1) + '  |'
        f = []
        j = i + 1
        while j < len(lines) and (lines[j].startswith(m.group(1) + '  ') ):
            if lines[j].startswith(ind) and not lines[j].startswith(ind + ' '):
                fl = lines[j][len(ind):]
                if not fl.startswith('vpiParent') and not fl.startswith('vpiFullName'):
                    f.append(fl.split('/')[0] if fl.startswith('vpiFile') else fl)
            j += 1
        out.append(f'{sec} {m.group(2)} {m.group(3)} ' + ';'.join(sorted(f)))
    i += 1
print('\n'.join(sorted(out)))
