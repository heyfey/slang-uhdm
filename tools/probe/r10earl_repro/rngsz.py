#!/usr/bin/env python3
# rngsz.py <dump> -- list every `range:` and its two bound children with
# kind/decompile/size, keyed by source line.  Projects a dump onto the ONLY
# fields uhdm-cmp reads for a range bound (VpiType/VpiSize/VpiConstType/
# VpiDecompile), so a bound-fold experiment is one diff.
import re
import sys

lines = open(sys.argv[1], encoding='utf-8', errors='replace').read().split('\n')
out = []
cur = None
for i, ln in enumerate(lines):
    m = re.search(r'\\_(range): , line:(\d+):(\d+)', ln)
    if m:
        cur = (int(m.group(2)), len(ln) - len(ln.lstrip()))
        continue
    m = re.search(r'\\_(constant|ref_obj|operation|sys_func_call|hier_path): *([^,]*), line:(\d+):(\d+)', ln)
    if m and cur is not None:
        ind = len(ln) - len(ln.lstrip())
        if ind <= cur[1]:
            cur = None
            continue
        kind = m.group(1)
        nm = m.group(2).strip()
        dec = sz = ct = ''
        for j in range(i, min(i + 12, len(lines))):
            d = re.search(r'\|vpiDecompile:(.*)', lines[j])
            if d and not dec:
                dec = d.group(1)
            z = re.search(r'\|vpiSize:(\d+)', lines[j])
            if z and not sz:
                sz = z.group(1)
            c = re.search(r'\|vpiConstType:(\d+)', lines[j])
            if c and not ct:
                ct = c.group(1)
            if re.search(r'\\_', lines[j]) and j > i:
                break
        out.append(f'rngline={cur[0]:3d} {kind:14s} {nm:24s} dec={dec:12s} sz={sz:3s} ct={ct}')
seen = set()
for o in out:
    if o in seen:
        continue
    seen.add(o)
    print(o)
