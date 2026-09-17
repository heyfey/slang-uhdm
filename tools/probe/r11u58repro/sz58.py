#!/usr/bin/env python3
# r11u58 — per-element size reader: for each param_assign in a section, print
# the tagged element name and the element's vpiSize (or '-' when absent).
import sys, re, subprocess
dump, sect = sys.argv[1], sys.argv[2]
out = subprocess.run(['python3','shape54.py',dump,sect],capture_output=True,text=True).stdout
for line in out.splitlines():
    m = re.match(r'\S+\s+(\S+)\s+(.*)', line)
    if not m: continue
    name, body = m.group(1), m.group(2)
    els = re.findall(r'string_typespec\(([A-Za-z_0-9]+)\)@[^}]*\}\[([a-z_]+)@[^{]*\{([^\[\]]*?)(?:\[|\}\])', body)
    if not els: continue
    cells=[]
    for (en, kind, attrs) in els:
        sm = re.search(r'vpiSize:(\d+)', attrs)
        cells.append(f"{en}={kind[:4]}:{sm.group(1) if sm else '-'}")
    print(f"{name:26s} " + " ".join(cells))
