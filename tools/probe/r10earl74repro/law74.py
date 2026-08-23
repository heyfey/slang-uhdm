#!/usr/bin/env python3
"""r10earl74 — THE LAW TEST.  For every unpacked SIZE-form dimension bound in a
database, print the bound constant's (ct, tag) next to the (ct, tag) of the
param_assign of the parameter that sizes it, in the SAME instance.  If the law
"the bound inherits the parameter's own elaborated encoding" holds, the two
columns are identical in GOLDEN on every row.

usage: law74.py <db.rg> <db.pa> <src.sv>
The dim parameter name is recovered from the source declaration of the owner.
"""
import sys, re, collections
rg, pa, src = sys.argv[1], sys.argv[2], sys.argv[3]
# owner-name -> sizing expression text, from the source
sizer = {}
for ln in open(src):
    m = re.search(r'(\w+)\s*\[([^\]:]+)\]\s*;', ln)
    if m and ':' not in m.group(2):
        sizer[m.group(1)] = m.group(2).strip()
# instance-chain -> {param: payload}
paof = collections.defaultdict(dict)
for ln in open(pa):
    f = ln.split()
    if f[0] != 'PA': continue
    chain, name = f[1], f[2]
    m = re.search(r'constant ct=(\d+) sz=(\d+) val=([A-Z]+):(\S+)', ln)
    if m: paof[chain][name] = (m.group(1), m.group(3), m.group(2), m.group(4))
rows = []
for ln in open(rg):
    if not ln.startswith('RG '): continue
    f = ln.rstrip('\n').split(' ', 2)
    chain, pay = f[1], f[2]
    m = re.search(r'R/op11\[0\]\{ct=(\d+) sz=(\d+) val=([A-Z]+):(\S+) dec=', pay)
    if not m: continue
    own = chain.split('/')[-1]
    ownname = own[own.find('(')+1:-1] if '(' in own else own
    inst = '/'.join(chain.split('/')[:-1])
    szexpr = sizer.get(ownname, '?')
    p = paof.get(inst, {}).get(szexpr.split('::')[-1])
    rows.append((ownname, szexpr, (m.group(1), m.group(3), m.group(2), m.group(4)), p))
seen = set()
tot = agree = nopa = 0
for own, sz, b, p in rows:
    k = (own, sz, b, p)
    if k in seen: continue
    seen.add(k)
    if p is None:
        nopa += 1; verdict = 'no-pa'
    else:
        tot += 1
        same = (b[0] == p[0] and b[1] == p[1])
        agree += same
        verdict = 'INHERIT' if same else 'DIFFERS'
    print('%-16s [%-14s] bound ct=%s %s sz=%s val=%s | param_assign %s  %s' %
          (own, sz, b[0], b[1], b[2], b[3],
           ('ct=%s %s sz=%s val=%s' % p) if p else '-', verdict))
print('\nSIZE-FORM BOUNDS WITH A param_assign IN THE SAME INSTANCE: %d, '
      'ENCODING INHERITED: %d, DIFFERS: %d  (no param_assign: %d)'
      % (tot, agree, tot - agree, nopa))
