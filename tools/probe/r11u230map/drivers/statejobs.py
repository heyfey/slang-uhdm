#!/usr/bin/env python3
"""r11u230map: the job lists of one landing-off state sweep for the landing's movement of the map (README section 3):
every STRICT_NOTEQUAL row-mode / probe case of the state sweep whose database differs from this map's pristine sweep
(or that is not STRICT_NOTEQUAL there), golden from the row's cmds.txt / check_probe's cache_dir. The rows whose
database is byte-identical keep the HEAD analysis (merged by statemerge in landing15.py).
Args: <repo> <state sweep dir> <pristine sweep dir> <out dir>   (writes <out>/jobs_int.tsv, <out>/probejobs.tsv)
Fence: a slang-fenced row is never listed (common.fenced(), fail closed)."""
import csv, os, re, sys, hashlib
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import fenced, is_fenced
REPO, S, P, OUT = sys.argv[1:5]
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import check_probe as cp
F = fenced(); os.makedirs(OUT, exist_ok=True)
md5 = lambda p: hashlib.md5(open(p, 'rb').read()).hexdigest() if os.path.exists(p) else None
def ne(p, key):
    return {key(r): r for r in csv.DictReader(open(p)) if r['status'].strip() == 'STRICT_NOTEQUAL'}
n = 0
with open(f'{OUT}/jobs_int.tsv', 'w') as f:
    for c in ('surelog', 'uhdm2rtlil'):
        s = ne(f'{S}/{c}.csv', lambda r: (r['mode'], r['name'])); p = ne(f'{P}/{c}.csv', lambda r: (r['mode'], r['name']))
        for (m, t), r in sorted(s.items()):
            if is_fenced(t, F): continue
            d = [x for x in os.listdir(f'{S}/{c}/{m}') if x.rsplit('-', 1)[0] == t][0]
            o = f'{S}/{c}/{m}/{d}/slang.uhdm'
            if (m, t) in p and md5(o) == md5(f'{P}/{c}/{m}/{d}/slang.uhdm'): continue
            g = re.search(r'golden cache (?:hit|stored?) (\S+?)\)', open(f'{S}/{c}/{m}/{d}/cmds.txt').read()).group(1) + '/golden.uhdm'
            f.write('\t'.join([c, m, t, g, o, r['strict']]) + '\n'); n += 1
k = 0
with open(f'{OUT}/probejobs.tsv', 'w') as f:
    s = ne(f'{S}/probe.csv', lambda r: r['case']); p = ne(f'{P}/probe.csv', lambda r: r['case'])
    for rel, r in sorted(s.items()):
        b = rel.replace('/', '__'); o = f'{S}/probe/{b}.uhdm'
        if rel in p and md5(o) == md5(f'{P}/probe/{b}.uhdm'): continue
        f.write('\t'.join(['probe', 'default', b, os.path.join(cp.cache_dir(rel), 'golden.uhdm'), o, rel]) + '\n'); k += 1
print('state jobs: corpus', n, 'probe', k)
