#!/usr/bin/env python3
"""r10rgg14/cen14.py — THE CENSUS.  Every CONSTANT that is the `vpiIndex` of a
`bit_select`, keyed by the bit_select's OWNER NAME and SPAN, with the four
Compare-relevant columns plus the value as a witness.  Emits one TSV row per
object; `--score` joins three files (golden, base, patched) as a MULTISET
(keys collide: one source line unrolls once per generate iteration, so a
last-writer dict would silently drop rows).

  usage: cen14.py <dump>            -> TSV rows on stdout
         cen14.py --score <g.tsv> <base.tsv> <pat.tsv>
"""
import sys, re, collections

def rows(fn):
    lines = open(fn).read().split('\n')
    ind = [len(l) - len(l.lstrip()) for l in lines]
    out = []
    for n, l in enumerate(lines):
        m = re.search(r'\\_bit_select: \(([^)]*)\), line:(\d+):(\d+), endln:(\d+):(\d+)', l)
        if not m:
            continue
        base = ind[n]
        k = n + 1
        while k < len(lines) and (ind[k] > base or not lines[k].strip()):
            if lines[k].strip() == '|vpiIndex:' and k + 1 < len(lines):
                cm = re.match(r'\s*\\_(\w+): ?(.*?), line:(\d+):(\d+), endln:(\d+):(\d+)',
                              lines[k + 1])
                if cm:
                    cb = ind[k + 1]
                    d = k + 2
                    f = {}
                    while d < len(lines) and ind[d] > cb:
                        s = lines[d].strip()
                        mm = re.match(r'\|(vpiDecompile|vpiSize|vpiConstType):(.*)', s)
                        if mm:
                            f[mm.group(1)] = mm.group(2)
                        elif re.match(r'\|(U?INT|BIN|HEX|OCT|DEC|REAL|STRING):', s):
                            f['VAL'] = s[1:]
                        d += 1
                    out.append((m.group(1),
                                '%s:%s-%s:%s' % (m.group(2), m.group(3),
                                                 m.group(4), m.group(5)),
                                cm.group(1),
                                '%s:%s-%s:%s' % (cm.group(3), cm.group(4),
                                                 cm.group(5), cm.group(6)),
                                f.get('vpiDecompile', ''), f.get('vpiSize', ''),
                                f.get('vpiConstType', ''), f.get('VAL', '')))
                break
            k += 1
    return out

def load(fn):
    d = collections.defaultdict(list)
    for line in open(fn):
        p = line.rstrip('\n').split('\t')
        if len(p) != 8:
            continue
        d[(p[0], p[1])].append(tuple(p[2:]))
    for v in d.values():
        v.sort()
    return d

if sys.argv[1] == '--score':
    g, b, p = (load(x) for x in sys.argv[2:5])
    keys = sorted(set(g) | set(b) | set(p))
    ok = fixed = broken = still = moved = 0
    for k in keys:
        G, B, P = g.get(k, []), b.get(k, []), p.get(k, [])
        if G == B == P:      ok += 1
        elif G != B and G == P:  fixed += 1;  print('FIXED  ', k, B, '->', P)
        elif G == B and G != P:  broken += 1; print('BROKEN ', k, B, '->', P)
        elif B == P:         still += 1
        else:                moved += 1;     print('MOVED-STILL-WRONG', k, B, '->', P, 'G=', G)
    print('keys=%d OK=%d FIXED=%d BROKEN=%d STILL=%d MOVED-STILL-WRONG=%d'
          % (len(keys), ok, fixed, broken, still, moved))
else:
    for r in rows(sys.argv[1]):
        print('\t'.join(r))
