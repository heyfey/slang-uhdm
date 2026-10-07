#!/usr/bin/env python3
# v11u285 keys.py <pattern> <db.uhdm>...: the chain-keyed records (r11u285repro/drivers/awayrows.py's keys, $SCX's raw
# walk) whose record or chain contains <pattern>, with their counts, per database. A decode aid for the away census;
# fail-closed on $FENCED (four names), a path naming a fenced test is refused before it is opened.
import os, re, sys
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('keys.py: FENCED unset')
for p in sys.argv[2:]:
    if any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', p) for f in F): sys.exit('keys.py: fenced path refused')
spec_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'r11u285repro', 'drivers', 'awayrows.py')
pat = sys.argv[1]; files = sys.argv[2:]
sys.argv = [sys.argv[0], '/nonexistent_off', '/nonexistent_on', '3']
src = open(spec_path).read().split('jobs = []')[0]; ns = {'__file__': spec_path}; exec(compile(src, spec_path, 'exec'), ns)
for f in files:
    K, _ = ns['keyed'](f); print('==', f.split('/')[-1])
    for k, v in sorted(K.items()):
        s = k[1] + ' @ ' + k[0]
        if pat in s: print(v, s[:260])
