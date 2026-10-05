#!/usr/bin/env python3
# (v11u250) ctlsum.py <controls.txt>: per case-view pristine / law / fix (controls3.sh lines): movers, entering and
# leaving STRICT_EQUAL, exit-code agreement, and whether the fix moves anything against the law.
import sys, re, collections
d = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    p = l.split()
    if len(p) < 3 or p[1] not in ('pristine', 'law', 'fix'): continue
    rc = re.search(r'rc=(\d+)', l); md = re.search(r'md5=(\w+)', l); cl = re.search(r'cmplines=(\d+)', l); st = re.search(r'strict=(\S+)', l)
    d[p[0]][p[1]] = dict(rc=rc.group(1) if rc else '?', md5=md.group(1) if md else p[2], cl=cl.group(1) if cl else '-', st=st.group(1) if st else p[2])
n = len(d); mv = ent = lv = rcdiff = fixmv = incomplete = 0
nz = collections.Counter()
for cv, m in sorted(d.items()):
    if set(m) != {'pristine', 'law', 'fix'}: incomplete += 1; continue
    P, L, F = m['pristine'], m['law'], m['fix']
    for t in (P, L, F):
        if t['rc'] != '0': nz[t['rc']] += 1
    if not (P['rc'] == L['rc'] == F['rc']): rcdiff += 1; print('RCDIFF', cv, P['rc'], L['rc'], F['rc'])
    pe = P['st'].startswith('STRICT_EQUAL'); le = L['st'].startswith('STRICT_EQUAL'); fe = F['st'].startswith('STRICT_EQUAL')
    if L['md5'] != P['md5']:
        mv += 1; ent += (le and not pe); lv += (pe and not le)
        print('MOVER', cv, P['cl'], P['st'], '->', L['cl'], L['st'], '| fix', F['cl'], F['st'])
    if F['md5'] != L['md5']: fixmv += 1; print('FIXMOVER', cv, L['cl'], L['st'], '->', F['cl'], F['st'])
    if pe and not fe: print('FIXLEAVES', cv)
print(f'# case-views {n} (incomplete {incomplete}); law movers {mv}, entering STRICT_EQUAL {ent}, leaving {lv}; '
      f'fix movers against law {fixmv}; exit codes differing {rcdiff}; non-zero exits per binary-run {dict(nz)}')
