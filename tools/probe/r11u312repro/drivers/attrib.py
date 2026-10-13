# (r11u312: copied from r11u310repro/drivers, renamed to R11U312 / r11u312)
# (r11u310: copied from r11u308repro/drivers, renamed to R11U310 / r11u310)
# (r11u308: copied from r11u306repro/drivers, renamed to R11U308 / r11u308)
# (r11u308: copied from r11u304repro/drivers, renamed to R11U308 / r11u308)
# (r11u308: copied from r11u302repro/drivers, renamed to R11U308 / r11u308)
#!/usr/bin/env python3
# (r11u308: copied from r11u300repro/drivers, renamed to R11U308 / r11u308)
# (r11u286: copied from r11u284repro/drivers; R11U312_* switches, R11U312_TRACE)
# r11u286 (copied from r11u284repro; r11u284 copied from r11u282repro) attrib.py  <gridall.txt> <attrib.txt>: per mover, the switches whose single-off run changes the law's bytes
# (the laws acting on that case-view); a mover whose single-off runs all keep the law's bytes needs a pair.
import sys, re, collections
rows = collections.defaultdict(dict)
for f in sys.argv[1:3]:
    for l in open(f):
        w = l.rstrip('\n').split(' ', 3)
        if len(w) == 4: rows[(w[0], w[1])][w[2]] = w[3]
md5 = lambda s: (re.search(r'md5=(\S+)', s) or [None, ''])[1]
combo = collections.Counter()
for (c, v), r in sorted(rows.items()):
    p, L = md5(r.get('pristine', '')), md5(r.get('law', ''))
    if p == L: continue
    acts = sorted(k[4:].replace('R11U312_', '').replace('_OFF', '') for k in r
                  if k.startswith('law+R11U312_') and k != 'law+R11U312_OFF' and md5(r[k]) != L)
    back = sorted(k[4:].replace('R11U312_', '').replace('_OFF', '') for k in r
                  if k.startswith('law+R11U312_') and k != 'law+R11U312_OFF' and md5(r[k]) == p)
    combo['+'.join(acts) or 'none'] += 1
    print(f'{c} {v} acting: {"+".join(acts) or "none"} single-off-back-to-pristine: {"+".join(back) or "-"}')
print('acting-law sets over the movers:', dict(combo))
