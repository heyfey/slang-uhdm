#!/usr/bin/env python3
"""r11u84 BOTH-MODE ROW JOIN — key (name, mode), payload status + dump column.
Only a law-named row may differ, and it must be quoted."""
import csv, sys
def rd(fns):
    d = {}
    for fn in fns:
        for r in csv.DictReader(open(fn)):
            d[(r['name'], r['mode'])] = (r['status'], r['dump'])
    return d
base, fresh = rd([sys.argv[1]]), rd(sys.argv[2:])
common = set(base) & set(fresh)
diff = sorted(k for k in common if base[k] != fresh[k])
print('base=%d fresh=%d common=%d only_base=%d only_fresh=%d DIFFER=%d'
      % (len(base), len(fresh), len(common),
         len(set(base) - set(fresh)), len(set(fresh) - set(base)), len(diff)))
for k in diff:
    print('  %-40s %s -> %s' % (k, base[k], fresh[k]))
print('PASS' if not diff else 'ATTENTION')
