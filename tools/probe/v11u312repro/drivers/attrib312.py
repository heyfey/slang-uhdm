# (v11u312: copied from r11u312repro/drivers)
#!/usr/bin/env python3
# r11u312 attrib312.py <grid.txt>: per mover (pristine md5 != law md5), the switches whose single-off run gives
# pristine's bytes back (RESTORE) and those that change the law's bytes at all (ACT); a mover no single switch
# restores needs two or more (its ACT list names them).  Prints one line per mover and a summary.
import sys, re, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    w = l.rstrip('\n').split(' ', 3)
    if len(w) == 4: rows[(w[0], w[1])][w[2]] = w[3]
md5 = lambda s: (re.search(r'md5=(\S+)', s) or [None, ''])[1]
single = collections.Counter(); multi = collections.Counter(); n = 0
for (c, v), r in sorted(rows.items()):
    p, L = md5(r['pristine']), md5(r['law'])
    if p == L: continue
    n += 1
    sw = sorted(k[len('law+R11U312_'):-4] for k in r if k.startswith('law+R11U312_') and k != 'law+R11U312_OFF')
    rest = [s for s in sw if md5(r['law+R11U312_%s_OFF' % s]) == p]
    act = [s for s in sw if md5(r['law+R11U312_%s_OFF' % s]) != L]
    if rest: single['+'.join(rest)] += 1
    else: multi['+'.join(act)] += 1
    print('MOVER %s %s RESTORE=%s ACT=%s' % (c, v, ','.join(rest) or '-', ','.join(act) or '-'))
print('SUMMARY movers=%d single=%d multi=%d' % (n, sum(single.values()), sum(multi.values())))
for k, x in single.most_common(): print('  single %s %d' % (k, x))
for k, x in multi.most_common(): print('  multi %s %d' % (k, x))
