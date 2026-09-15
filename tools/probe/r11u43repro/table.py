#!/usr/bin/env python3
# r11u43 — the GOLDEN GRID table: golden vs ours, per arm, ALL views (the
# scorer emits one row per distinct constant object, so an arm whose two views
# disagree shows two rows).  Measurement-only.
import sys, re, collections
def load(p, tag):
    d = collections.OrderedDict()
    for ln in open(p):
        f = ln.split()
        if len(f) < 3: continue
        a = f[1]
        if f[2] in ('NODB', 'NOCONST', 'DUMPFAIL'):
            d.setdefault(a, []).append(f[2]); continue
        m = re.search(r'size=(-?\d+) (\S+) ct=(\d+)', ln)
        if not m: continue
        v = m.group(2)
        if len(v) > 18: v = v[:8] + '…' + v[-4:]
        d.setdefault(a, []).append('%s/%s/ct%s' % (m.group(1), v, m.group(3)))
    return d
g = load(sys.argv[1], 'G'); o = load(sys.argv[2], 'O')
print('%-5s %-34s %-34s %s' % ('arm', 'GOLDEN', 'OURS(pristine)', 'verdict'))
for a in sorted(set(g) | set(o)):
    gv = g.get(a, ['-']); ov = o.get(a, ['-'])
    gs = ' | '.join(gv); os_ = ' | '.join(ov)
    if 'NODB' in ov: verdict = 'SLANG_REJECT'
    elif gs == os_: verdict = 'EQ'
    else: verdict = 'DIFF'
    print('%-5s %-34s %-34s %s' % (a, gs, os_, verdict))
