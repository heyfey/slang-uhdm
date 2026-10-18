#!/usr/bin/env python3
# gridsum401.py <grid.txt>: per case-view pristine vs law verdict, R11U401_OFF == pristine md5,
# and which single switch restores pristine bytes on a mover.
import sys, re, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    p = l.split(None, 3)
    if len(p) < 4: continue
    case, view, lab, rest = p
    md = re.search(r'md5=(\S+)', rest); v = re.sub(r' md5=\S+', '', rest.strip())
    rows[(case, view)][lab] = (v, md.group(1) if md else None)
n = mov = off_eq = 0; enter = leave = 0; out = []
for k, d in sorted(rows.items()):
    n += 1
    pv, pm = d['pristine']; lv, lm = d['law']; ov, om = d['law+R11U401_OFF']
    off_eq += om == pm
    moved = pm != lm
    mov += moved
    pe = 'STRICT_EQUAL' in pv; le = 'STRICT_EQUAL' in lv
    enter += (le and not pe); leave += (pe and not le)
    rest = [lab[4:] for lab, (vv, mm) in d.items() if lab.startswith('law+R11U401_') and lab != 'law+R11U401_OFF' and mm == pm] if moved else []
    out.append(f"{k[0]} {k[1]} | {pv} -> {lv} | moved={int(moved)} restoredBy={','.join(rest) or '-'}")
print('\n'.join(out))
print(f'case-views={n} moving={mov} entering_STRICT_EQUAL={enter} leaving={leave} R11U401_OFF==pristine {off_eq}/{n}')
