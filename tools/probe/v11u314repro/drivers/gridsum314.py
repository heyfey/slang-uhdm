# (r11u314: copied from r11u312repro/drivers, renamed to R11U314 / r11u314)
# (r11u314: copied from r11u310repro/drivers, renamed to R11U314 / r11u314)
# (r11u310: copied from r11u308repro/drivers, renamed to R11U310 / r11u310)
#!/usr/bin/env python3
# r11u314 gridsum310.py (copied from r11u308repro gridsum308.py) <grid.txt> <movers out>: pristine vs law per case-view (database md5), law+R11U314_OFF
# against pristine, entering / leaving STRICT_EQUAL, exit-code and uhdm-cmp line changes, per group; writes the
# MOVER list awaygrid.sh and attrib308.sh read.
import sys, collections
L = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    w = l.split(); L[(w[0], w[1])][w[2]] = ' '.join(w[3:])
md = lambda s: s.split('md5=')[-1] if 'md5=' in s else s
g = collections.defaultdict(lambda: [0, 0, 0, 0, 0]); movers = []; off = rc = cm = 0
for k, d in sorted(L.items()):
    p, l, o = d['pristine'], d['law'], d['law+R11U314_OFF']; grp = k[0].split('/')[0]
    g[grp][0] += 1
    if md(o) != md(p) or o.split()[0] != p.split()[0]: off += 1; print('OFFDIFF', *k)
    if p.split()[0] != l.split()[0]: rc += 1; print('RCCHANGE', *k, p, '->', l)
    if p.split()[1] != l.split()[1]: cm += 1; print('CMPCHANGE', *k, p.split()[1], '->', l.split()[1])
    if md(p) != md(l):
        g[grp][1] += 1; movers.append(k)
        if 'STRICT_EQUAL' in l and 'STRICT_EQUAL' not in p: g[grp][2] += 1
        if 'STRICT_EQUAL' in p and 'STRICT_EQUAL' not in l: g[grp][3] += 1; print('LEAVE', *k)
    if 'STRICT_EQUAL' in l: g[grp][4] += 1
t = [0] * 5
for k in sorted(g):
    print('%s case-views=%d moving=%d entering=%d leaving=%d equal-after=%d' % ((k,) + tuple(g[k])))
    t = [a + b for a, b in zip(t, g[k])]
print('TOTAL case-views=%d moving=%d entering=%d leaving=%d equal-after=%d off!=pristine=%d rc-changed=%d cmp-changed=%d' % (tuple(t) + (off, rc, cm)))
open(sys.argv[2], 'w').write(''.join('MOVER %s %s:\n' % k for k in movers))
