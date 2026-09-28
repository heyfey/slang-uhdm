#!/usr/bin/env python3
"""r11u187: every CHANGE / CONVERSION of a law sweep, judged against the pristine sweep: the strict head (first
differing record) of each, where the index-aligned walk diverges (first record whose depth or type differs), and
the ORDER-BLIND record distance to golden (uhdm-strictcmp record multisets, depth dropped, both directions summed):
TOWARD / SAME / AWAY.  usage: chgcheck.py <pristine sweep> <law sweep> <item>...  where item is
corpus/mode/test or probe/<case rel path>.  Fence-refusing (reads the FENCED= line of r11u107repro/canaudit.sh)."""
import sys, os, re, glob, subprocess, collections
HERE = os.path.dirname(os.path.abspath(__file__)); REPO = os.path.abspath(os.path.join(HERE, '../../../..'))
fen = re.search(r'^FENCED="(.*)"$', open(os.path.join(REPO, 'tools/probe/r11u107repro/canaudit.sh')).read(), re.M).group(1).split()
assert len(fen) == 4, 'fence unreadable'
FRE = re.compile(r'\b(' + '|'.join(map(re.escape, fen)) + r')\b')
sys.path.insert(0, os.path.join(REPO, 'scripts'))
SC = os.environ.get('STRICT_CMP', '/tmp/r11u192_bin/uhdm-strictcmp')
T = '/tmp/r11u192_chg'; os.makedirs(T, exist_ok=True)
P, L = sys.argv[1:3]
def locate(W, item):
    if item.startswith('probe/'):
        import check_probe as cp
        rel = item[6:]
        return cp.cache_dir(rel) , os.path.join(W, 'probe', rel.replace('/', '__') + '.uhdm')
    c, m, t = item.split('/')
    d = glob.glob(f'{W}/{c}/{m}/{t}-*')[0]
    g = re.search(r'golden cache (?:hit|store) ([^)]*)\)', open(d + '/cmds.txt').read()).group(1)
    return g, d + '/slang.uhdm'
def recs(g, o, tag):
    gu = os.path.join(g, 'golden.uhdm') if os.path.isdir(g) else g
    if not os.path.exists(gu):
        gu = (glob.glob(os.path.join(g, '*.uhdm')) or [gu])[0]
    a, b = f'{T}/{tag}.a', f'{T}/{tag}.b'
    r = subprocess.run([SC, '--max', '1', '--dump-a', a, '--dump-b', b, gu, o], capture_output=True, text=True)
    head = [l for l in r.stdout.splitlines() if l.strip()]
    return a, b, head
def ob(a, b):
    A = collections.Counter('\t'.join(l.rstrip('\n').split('\t')[1:]) for l in open(a, errors='replace'))
    B = collections.Counter('\t'.join(l.rstrip('\n').split('\t')[1:]) for l in open(b, errors='replace'))
    return sum((B - A).values()) + sum((A - B).values())
def div(a, b):
    with open(a, errors='replace') as fa, open(b, errors='replace') as fb:
        for i, (x, y) in enumerate(zip(fa, fb)):
            if x.split('\t')[:2] != y.split('\t')[:2]:
                return i
    return 'never'
for item in sys.argv[3:]:
    if FRE.search(item):
        print(item, 'FENCED: refused'); continue
    out = []
    for W, tag in ((P, 'P'), (L, 'L')):
        g, o = locate(W, item)
        a, b, head = recs(g, o, tag)
        out.append((ob(a, b), div(a, b), ' / '.join(head[:3]) if head else ''))
    (dp, vp, hp), (dl, vl, hl) = out
    verdict = 'TOWARD' if dl < dp else 'AWAY' if dl > dp else 'SAME'
    print(f'{item}\tobdist {dp} -> {dl} {verdict}\tdivergence {vp} -> {vl}\n   P head: {hp}\n   L head: {hl}')
