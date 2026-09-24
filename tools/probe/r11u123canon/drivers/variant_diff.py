#!/usr/bin/env python3
"""Root-set experiment readout: a variant's verdicts against the canonical patch's
(runall.csv can_v): conversions (-> equal), regressions (equal -> differ), first-field
moves, and time.  usage: variant_diff.py <runall.csv> <variant.csv> [...]"""
import collections, csv, sys
base = {(r['corpus'], r['test'], r['mode']): r for r in csv.DictReader(open(sys.argv[1]))}
for p in sys.argv[2:]:
    v = {(r['corpus'], r['test'], r['mode']): r for r in csv.DictReader(open(p))}
    conv = sorted(k for k in base if base[k]['can_v'] != 'equal' and v[k]['verdict'] == 'equal')
    regr = sorted(k for k in base if base[k]['can_v'] == 'equal' and v[k]['verdict'] != 'equal')
    moved = collections.Counter(f"{base[k]['can_v'].split('(')[0]}->{v[k]['verdict'].split('(')[0]}"
                                for k in base if base[k]['can_v'] != 'equal' and v[k]['verdict'] != 'equal'
                                and base[k]['can_v'].split('(')[0] != v[k]['verdict'].split('(')[0])
    special = collections.Counter(v[k]['verdict'] for k in v if v[k]['verdict'] in ('overflow', 'timeout') or ':rc' in v[k]['verdict'])
    secs = sum(float(v[k]['secs']) for k in v)
    slow = sorted(((float(v[k]['secs']), '/'.join(k)) for k in v), reverse=True)[:3]
    eq = sum(v[k]['verdict'] == 'equal' for k in v)
    print(f'== {p}: equal {eq} (canon patch {sum(b["can_v"] == "equal" for b in base.values())}); '
          f'conversions {len(conv)}; regressions {len(regr)}; overflow/timeout/crash {dict(special)}; '
          f'total secs {secs:.0f}; slowest {slow}')
    for k in conv:
        print('   +', '/'.join(k), base[k]['can_v'])
    for k in regr:
        print('   -', '/'.join(k), v[k]['verdict'])
    print('   first-field moves:', dict(moved.most_common(12)))
