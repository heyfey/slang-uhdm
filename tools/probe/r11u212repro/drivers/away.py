#!/usr/bin/env python3
"""r11u209 (copied from r11u205dec): map 12's AWAY-MOVED-RECORD census (order-blind, depth dropped, multisets) of the law sweep against the
pristine sweep, per row-mode or probe case: LOST = records golden and the PRISTINE database share that the LAW database
no longer has (a field moved away from golden); GAINED = golden records the law database has and pristine had not.
usage: away.py <pristine sweep wd> <law sweep wd> <list file: 'corpus mode test' or 'probe - <rel>' per line>
Fence: refuses any row naming a fenced test (FENCED= line of r11u107repro/canaudit.sh; fail closed)."""
import sys, os, re, glob, subprocess, collections, tempfile
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
F = None
for l in open(os.path.join(REPO, 'tools/probe/r11u107repro/canaudit.sh')):
    if l.startswith('FENCED='): F = re.sub(r'["\']', '', l[len('FENCED='):]).split()
assert F and len(F) == 4, 'fence unreadable: refusing'
SC = os.environ.get('STRICT_CMP', '/home/heyfey/git-repos/slang-uhdm/build/uhdm-strictcmp')
P, L, lst = sys.argv[1:4]
T = tempfile.mkdtemp(prefix='r11u212_away_')
def ms(p):
    c = collections.Counter()
    for l in open(p, errors='replace'):
        if '\t' in l: c[l.rstrip('\n').split('\t', 1)[1]] += 1
    return c
def dbs(wd, corp, mode, name):
    if corp == 'probe':
        import check_probe as cp
        return os.path.join(cp.cache_dir(name), 'golden.uhdm'), os.path.join(wd, 'probe', name.replace('/', '__') + '.uhdm')
    d = glob.glob(f'{wd}/{corp}/{mode}/{name}-*/')
    if not d: return None, None
    m = re.search(r'golden cache [a-z]* *([^ )]*)', open(d[0] + 'cmds.txt').read())
    return os.path.join(m.group(1), 'golden.uhdm'), d[0] + 'slang.uhdm'
tot = collections.Counter(); shapes = collections.Counter()
for line in open(lst):
    f = line.split()
    if len(f) < 3: continue
    corp, mode, name = f[:3]
    if any(re.search(r'(?<![A-Za-z0-9_])' + re.escape(x) + r'(?![A-Za-z0-9_])', name) for x in F):
        print('FENCED-REFUSED'); continue
    g, pdb = dbs(P, corp, mode, name); _, ldb = dbs(L, corp, mode, name)
    if not (g and pdb and ldb and os.path.exists(g) and os.path.exists(pdb) and os.path.exists(ldb)):
        print('MISSING', corp, mode, name); continue
    for tag, db in (('p', pdb), ('l', ldb)):
        subprocess.run([SC, '--max', '0', '--dump-a', f'{T}/a', '--dump-b', f'{T}/{tag}', g, db],
                       capture_output=True, timeout=1200)
    G, Pb, Lb = ms(f'{T}/a'), ms(f'{T}/p'), ms(f'{T}/l')
    shared = G & Pb; kept = G & Lb
    lost = shared - kept; gained = kept - shared
    nl, ng = sum(lost.values()), sum(gained.values())
    print(f'{corp}/{mode}/{name} lost={nl} gained={ng} net={ng - nl}')
    for r, k in lost.items():
        print(f'   LOST {k} {r[:200]!r}')
        shapes[r.split('\t')[0]] += k
    tot['lost'] += nl; tot['gained'] += ng
print('TOTAL', dict(tot), 'lost by type', dict(shapes))
