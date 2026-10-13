# (v11u304: copied from r11u304repro/drivers, scratch renamed to /tmp/v11u304_*)
# (r11u304: copied from r11u302repro/drivers, renamed to R11U304 / r11u304)
#!/usr/bin/env python3
# (r11u304: copied from r11u300repro/drivers, renamed to R11U304 / r11u304)
# (r11u286: copied from r11u284repro/drivers; R11U288_* switches, R11U288_TRACE)
# (r11u282: copied from r11u280repro/drivers)
# (r11u280: copied from r11u278repro/drivers)
# r11u280 ctlsum.py <controls.txt>: pristine against the law per case-view (database md5): movers, entering /
# leaving STRICT_EQUAL, exit-code and uhdm-cmp line changes.
import sys, re, collections
r = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    w = l.split(' ', 3)
    if len(w) == 4: r[(w[0], w[1])][w[2]] = w[3].strip()
def f(s, k):
    m = re.search(k + r'=(\S+)', s); return m.group(1) if m else ''
n = mv = en = le = rc = cm = 0
for k, v in sorted(r.items()):
    p, L = v.get('pristine', ''), v.get('law', ''); n += 1
    if f(p, 'rc') != f(L, 'rc'): rc += 1
    if f(p, 'cmp') != f(L, 'cmp'): cm += 1
    if f(p, 'md5') == f(L, 'md5'): continue
    mv += 1; e = 'STRICT_EQUAL' in L and 'STRICT_EQUAL' not in p; x = 'STRICT_EQUAL' in p and 'STRICT_EQUAL' not in L
    en += e; le += x
    print('MOVER', k[0], k[1], re.sub(r' md5=\S+', '', p), '->', re.sub(r' md5=\S+', '', L))
print(f'case-views={n} moving={mv} entering={en} leaving={le} rc-changed={rc} cmplines-changed={cm}')
