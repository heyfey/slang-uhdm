# (r11u308: copied from r11u306repro/drivers, renamed to R11U308 / r11u308)
# (r11u308: copied from r11u304repro/drivers, renamed to R11U308 / r11u308)
# (r11u308: copied from r11u302repro/drivers, renamed to R11U308 / r11u308)
#!/usr/bin/env python3
# r11u308 gridsum302.py <grid.txt>: one line per case-view: pristine verdict | law verdict, MOVE when the
# database moved, OFFOK when law+R11U308_OFF gives pristine's md5, and the switches that restore the law to
# pristine's md5 on their own (RESTORE) or that change the law's md5 at all (MOVES).
import re, sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    w = l.split()
    rows[(w[0], w[1])][w[2]] = ' '.join(w[3:])
def v(r):
    m = re.search(r'rc=(\S+) (?:cmp=(\S+) (.*?) md5=(\S+)|(\S+))', r)
    return (m.group(1), m.group(2), m.group(3), m.group(4) or m.group(5)) if m else (r, '', '', '')
for k in sorted(rows):
    d = rows[k]; p = v(d['pristine']); L = v(d['law']); off = v(d['law+R11U308_OFF'])
    rest = [lab.split('+', 1)[1] for lab in d if lab.startswith('law+R11U308_') and lab != 'law+R11U308_OFF' and v(d[lab])[3] == p[3]]
    mv = [lab.split('+', 1)[1] for lab in d if lab.startswith('law+R11U308_') and lab != 'law+R11U308_OFF' and v(d[lab])[3] != L[3]]
    print(k[0], k[1], 'P: rc=%s cmp=%s %s | L: rc=%s cmp=%s %s' % (p[0], p[1], p[2], L[0], L[1], L[2]),
          'MOVE' if p[3] != L[3] else 'SAME', 'OFFOK' if off[3] == p[3] else 'OFFBAD',
          'RESTORE=' + ','.join(x.replace('R11U308_', '').replace('_OFF', '') for x in rest),
          'MOVES=' + ','.join(x.replace('R11U308_', '').replace('_OFF', '') for x in mv))
