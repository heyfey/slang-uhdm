#!/usr/bin/env python3
# (v11u253: copied from r11u253repro/drivers)
# (r11u253) gridsum.py <grid.txt>: one line per case-view (pristine -> law strict verdicts, uhdm-cmp exit codes, the
# switches whose single drop moves the law's bytes), then the totals: case-views, R11U253_OFF == pristine bytes,
# entering / leaving STRICT_EQUAL, uhdm-cmp line counts rising, non-zero exit codes.
import collections, sys
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    rows[f[0]][f[1]] = dict(x.split('=', 1) for x in f[2:] if '=' in x)
tot = offok = enter = leave = rise = badrc = 0
for c in sorted(rows):
    r = rows[c]; tot += 1
    p, lw, off = r['pristine'], r['law'], r['lawOFF']
    offok += off.get('md5') == p.get('md5')
    pe = p.get('strict', '').startswith('STRICT_EQUAL'); le = lw.get('strict', '').startswith('STRICT_EQUAL')
    enter += le and not pe; leave += pe and not le
    rise += int(lw.get('cmplines', 0)) > int(p.get('cmplines', 0))
    badrc += sum(1 for t in r.values() if t.get('rc') != '0')
    sw = [t[4:].replace('R11U253_', '').replace('_OFF', '') for t in r if t.startswith('law-') and r[t].get('md5') != lw.get('md5')]
    print(c, p.get('strict'), 'cmp=' + p.get('cmp', '?'), '->', lw.get('strict'), 'cmp=' + lw.get('cmp', '?'), ','.join(sw) or '-')
print(f'case-views {tot}; R11U253_OFF==pristine {offok}; entering STRICT_EQUAL {enter}; leaving {leave}; '
      f'cmp lines rising {rise}; non-zero exits {badrc}')
