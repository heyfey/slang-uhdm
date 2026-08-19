#!/usr/bin/env python3
"""r10buvm25repro/cencmp25.py — MULTISET join of two r10buvm25cen censuses.

MEASUREMENT ONLY.  LHS is ALWAYS golden; RHS is ALWAYS ours.

Key   = (key=..., view=...)   — the SITE and the VIEW, never the file
        (our expression nodes carry an EMPTY VpiFile, buvm16 §4) and never
        the value fields.
Value = the loop variable's KIND + its typespec (kind;name;loc) [+ arr= when
        --witharr], as a SORTED MULTISET per key, so colliding keys never drop
        rows the way a last-writer dict does (buvm22's trap).

Prints, per (view, golden-value -> ours-value) class, the count; then the
totals AGREE / DIFFER, and with --x an example key per differing class.
"""
import sys, collections, re

def load(p, witharr, noloc=False):
    d = collections.defaultdict(list)
    for ln in open(p):
        if not ln.startswith('LV '): continue
        m = re.match(r'LV \S+ key=(.*?) view=(\S+) lv=(\S+) lvts=(\S+) ext=(\S+) nr=(\S+) arr=(\S+) hk=(\S+) ch=(\S+)', ln.strip())
        if not m:
            sys.exit('unparsed: ' + ln)
        key, view, lv, lvts, ext, nr, arr, hk, ch = m.groups()
        if noloc: lvts = ';'.join(lvts.split(';')[:2])
        val = lv + ' | ' + lvts
        if witharr:
            if noloc: arr = ';'.join(arr.split(';')[:4])
            val += ' | arr=' + arr
        d[(key, view)].append(val)
    for k in d: d[k].sort()
    return d

def main():
    a = [x for x in sys.argv[1:] if not x.startswith('--')]
    witharr = '--witharr' in sys.argv
    noloc = '--noloc' in sys.argv
    show = '--x' in sys.argv
    G, O = load(a[0], witharr, noloc), load(a[1], witharr, noloc)
    cls = collections.Counter(); ex = {}
    agree = differ = gonly = oonly = 0
    for k in sorted(set(G) | set(O)):
        g, o = G.get(k), O.get(k)
        if g is None: oonly += len(o); cls[(k[1], '<no-such-site>', ';'.join(o))] += 1; ex.setdefault((k[1],'<no-such-site>',';'.join(o)), k); continue
        if o is None: gonly += len(g); cls[(k[1], ';'.join(g), '<no-such-site>')] += 1; ex.setdefault((k[1],';'.join(g),'<no-such-site>'), k); continue
        if g == o: agree += len(g); continue
        differ += max(len(g), len(o))
        c = (k[1], ';'.join(g), ';'.join(o))
        cls[c] += 1; ex.setdefault(c, k)
    for (view, g, o), n in cls.most_common():
        print('%6d  %-9s  G[%s]  ->  O[%s]' % (n, view, g, o))
        if show: print('           e.g. %s' % (ex[(view,g,o)],))
    print('TOTAL agree=%d differ=%d golden-only-site=%d ours-only-site=%d sites_g=%d sites_o=%d'
          % (agree, differ, gonly, oonly, len(G), len(O)))

main()
