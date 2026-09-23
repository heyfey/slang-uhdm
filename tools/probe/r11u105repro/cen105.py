#!/usr/bin/env python3
"""r11u105 census joiner (r11u103 cen103.py lineage), GOLDEN FIRST.  MEASUREMENT ONLY.

  cen105.py <ct105cen> <scratch> <sweep-workdir>... [--seed <arm-dir>:<tag>]...

For every test cell of the sweep workdirs (one cmds.txt each) the golden is the
golden-cache database the cmds.txt names and ours is the cell's slang.uhdm.
Seeds are grid arm dirs (slpp_all/surelog.uhdm vs ours.<tag>.uhdm) dispatched
exactly like a corpus cell: the POSITIVE CONTROL.  Printed per cell:
  NAMESAKE-GOLD / NAMESAKE-OURS  <kind> <X>: golden (ours) publishes a nested
                                 `work@<outer>::X` module AND a file-scope X as a
                                 MOD (AllModules), TOP (TopModules), PROG
                                 (AllPrograms) or IFACE (AllInterfaces) -- the
                                 superset of all three laws' shapes
  ENTRY-GOLD-ONLY <def>          golden lists the definition, ours does not
  PORTS-GOLD-ONLY <def> g=<n>    golden's entry has ports, ours has none
                                 (LAW B's cell; pre-existing causes included)
Definition entries are DEDUPED per database before the join (multiset trap).
"""
import os, re, subprocess, sys
from collections import defaultdict

ct, scr = sys.argv[1], sys.argv[2]
args = sys.argv[3:]
seeds, wds = [], []
i = 0
while i < len(args):
    if args[i] == '--seed':
        seeds.append(args[i + 1]); i += 2
    else:
        wds.append(args[i]); i += 1
os.makedirs(scr, exist_ok=True)
cells = []   # (label, gold, ours)
for wd in wds:
    for root, _, files in os.walk(wd):
        if 'cmds.txt' not in files:
            continue
        txt = open(os.path.join(root, 'cmds.txt')).read()
        m = re.search(r'golden cache [a-z]+ (\S+?)\)', txt)
        gold = os.path.join(m.group(1), 'golden.uhdm') if m else None
        ours = os.path.join(root, 'slang.uhdm')
        cells.append((os.path.relpath(root, wd) + '@' + os.path.basename(wd.rstrip('/')),
                      gold if gold and os.path.isfile(gold) else None,
                      ours if os.path.isfile(ours) else None))
for sd in seeds:
    d, tag = sd.rsplit(':', 1)
    g = os.path.join(d, 'slpp_all', 'surelog.uhdm'); o = os.path.join(d, 'ours.%s.uhdm' % tag)
    cells.append(('SEED/' + os.path.basename(d.rstrip('/')), g if os.path.isfile(g) else None,
                  o if os.path.isfile(o) else None))
dbs = sorted({p for c in cells for p in c[1:] if p})
lst = os.path.join(scr, 'dbs.txt')
open(lst, 'w').write('\n'.join(dbs) + '\n')
env = dict(os.environ, LD_LIBRARY_PATH=os.path.expanduser('~/.local/lib64') + ':' + os.path.expanduser('~/.local/lib'))
out = subprocess.run([ct], stdin=open(lst), capture_output=True, text=True, env=env).stdout
defs = defaultdict(dict); ns = defaultdict(set); fails = set()
for ln in out.splitlines():
    p = ln.split()
    if p[0] == 'DEF':
        defs[p[1]][p[2]] = max(defs[p[1]].get(p[2], 0), int(p[3].split('=')[1]))
    elif p[0] == 'NAMESAKE':
        ns[p[1]].add(p[2] + ' ' + p[3])
    elif p[0] == 'RESTORE_FAIL':
        fails.add(p[1])
print('#', out.splitlines()[-1] if out else 'NO OUTPUT')
n = dict(cells=len(cells), gold=0, ours=0, both=0, nsg=0, nso=0, entry=0, ports=0)
for label, g, o in cells:
    n['gold'] += bool(g); n['ours'] += bool(o); n['both'] += bool(g and o)
    for x in sorted(ns.get(g, ())):
        print('NAMESAKE-GOLD', label, x); n['nsg'] += 1
    for x in sorted(ns.get(o, ())):
        print('NAMESAKE-OURS', label, x); n['nso'] += 1
    if not (g and o):
        continue
    gd, od = defs.get(g, {}), defs.get(o, {})
    for d, np in sorted(gd.items()):
        if d not in od:
            print('ENTRY-GOLD-ONLY', label, d, 'g=%d' % np); n['entry'] += 1
        elif np > 0 and od[d] == 0:
            print('PORTS-GOLD-ONLY', label, d, 'g=%d' % np); n['ports'] += 1
print('# CELLS %(cells)d gold=%(gold)d ours=%(ours)d paired=%(both)d NAMESAKE-GOLD=%(nsg)d '
      'NAMESAKE-OURS=%(nso)d ENTRY-GOLD-ONLY=%(entry)d PORTS-GOLD-ONLY=%(ports)d' % n)
