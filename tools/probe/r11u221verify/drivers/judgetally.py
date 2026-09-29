#!/usr/bin/env python3
# (r11u217) judgetally.py <grid output>...: from grid.py's per-state lines (`<case-view> <tag> cmp=.. strict=..`), the
# judge-level status per case-view in three states: alloff (the three landings off), law (fix.bin with R11V217_OFF =
# the base's bytes: tag offL217, or `on` when the case names no law with a 217v child) and fix (`on` on fix.bin);
# EQUAL = uhdm-cmp 0 lines and STRICT_EQUAL; JE = judge-equal, strict not equal; NE = stage 1.  Prints the transition
# tallies and the case-views leaving EQUAL.
import re, sys, collections
st = collections.defaultdict(dict)
for f in sys.argv[1:]:
    for l in open(f, errors='replace'):
        m = re.match(r'\s+(\S+) (\S+) cmp=(\d+) cmplines=\d+ strict=(\S+) rc=(\d+)', l)
        if not m: continue
        cv, tag, cmp_, s, rc = m.groups()
        v = 'EQUAL' if s.startswith('STRICT_EQUAL') else ('NE' if 'stage1' in s or cmp_ != '0' else 'JE')
        st[cv][tag] = v
T = collections.Counter(); leave = []
for cv, d in sorted(st.items()):
    a = d.get('alloff'); law = d.get('offL217', d.get('on')); fx = d.get('on')
    T[(a, law, fx)] += 1
    if a == 'EQUAL' and law != 'EQUAL': leave.append((cv, 'law', a, law))
    if law == 'EQUAL' and fx != 'EQUAL': leave.append((cv, 'fix', law, fx))
print('case-views', len(st))
for k, n in sorted(T.items(), key=lambda x: -x[1]): print(f'  {n:4d}  alloff={k[0]} law={k[1]} fix={k[2]}')
print('leaving EQUAL:', leave or 'none')
