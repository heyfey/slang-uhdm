#!/usr/bin/env python3
"""Per-cell $-constant table: golden vs pristine-ours vs patched-ours.

For each `constant` in a dump, key = (line,col,endline,endcol) + decompile,
value = (parentkind, size, consttype).  Prints only rows whose decompile is '$'
plus a summary of NON-$ differences between the two ours-dumps.
"""
import re, sys, os

def consts(path):
    lines = open(path).read().split('\n')
    out = {}
    for i, l in enumerate(lines):
        m = re.match(r'(\s*)\\_constant: , line:(\d+):(\d+), endln:(\d+):(\d+)', l)
        if not m: continue
        nxt = lines[i+1].strip() if i+1 < len(lines) else ''
        par = '-'
        if nxt == '|vpiParent:':
            pm = re.match(r'\\_(\w+):', lines[i+2].strip())
            par = pm.group(1) if pm else '?'
        dec = size = ct = ''
        for j in range(i+1, min(len(lines), i+12)):
            t = lines[j].strip()
            dm = re.match(r'\|vpiDecompile:(.*)$', t)
            if dm and not dec: dec = dm.group(1)
            sm = re.match(r'\|vpiSize:(-?\d+)$', t)
            if sm and not size: size = sm.group(1)
            cm = re.match(r'\|vpiConstType:(\d+)$', t)
            if cm and not ct: ct = cm.group(1)
        k = (int(m.group(2)), int(m.group(3)), int(m.group(4)), int(m.group(5)), dec)
        out.setdefault(k, []).append('%s/sz%s/ct%s' % (par, size, ct))
    return out

def norm(d):
    return {k: sorted(v) for k, v in d.items()}

g = norm(consts(os.path.join(sys.argv[1], 'g.dump')))
p = norm(consts(os.path.join(sys.argv[2], 'o.dump')))
q = norm(consts(os.path.join(sys.argv[3], 'o.dump')))
keys = sorted(set(g) | set(p) | set(q))
print('%-22s %-6s %-30s %-30s %-30s' % ('line:col-end', 'dec', 'GOLD', 'PRIS', 'PATCHED'))
nreg = 0
for k in keys:
    if k[4] != '$': continue
    gv, pv, qv = g.get(k, ['<absent>']), p.get(k, ['<absent>']), q.get(k, ['<absent>'])
    flag = ''
    if gv == pv and gv != qv:
        flag = '  <<< PRIS-RIGHT PATCHED-WRONG'; nreg += 1
    elif gv != pv and gv == qv:
        flag = '  >>> FIXED'
    elif gv != qv:
        flag = '  (both wrong)'
    print('%-22s %-6s %-30s %-30s %-30s%s' % ('%d:%d-%d:%d' % k[:4], k[4],
          ','.join(gv), ','.join(pv), ','.join(qv), flag))
print('-- $rows=%d  REGRESSIONS=%d' % (sum(1 for k in keys if k[4]=='$'), nreg))
# non-$ constant differences pristine vs patched
nd = 0
for k in keys:
    if k[4] == '$': continue
    if p.get(k) != q.get(k):
        nd += 1
        print('NON-$ CONST MOVED %s dec=%r PRIS=%s PATCHED=%s' % (k[:4], k[4], p.get(k), q.get(k)))
print('-- non-$ constant rows moved pristine->patched: %d' % nd)
