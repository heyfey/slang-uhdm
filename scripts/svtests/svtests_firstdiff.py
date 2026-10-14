#!/usr/bin/env python3
"""First-difference census over kept non-identical rows: dump both databases,
normalize ids and work paths, take the first unified-diff hunk and record its
first three changed lines.  Clusters by the normalized first changed line."""
import csv, os, re, subprocess, sys, collections, difflib
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.environ.get('SLANG_UHDM_REPO') or os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import verify_golden as vg  # noqa: E402
DUMP = vg._tool('UHDM_DUMP', *[os.path.join(d, 'uhdm-dump') for d in vg._UHDM_BINS])
def norm(t):
    t = re.sub(r'\bid:\d+', 'id:_', t)
    t = re.sub(re.escape(WORKROOT) + r'/[^ ,\n]*/', '', t)
    return t
def dump(db):
    r = subprocess.run([DUMP, db], capture_output=True, text=True, timeout=600)
    return norm(r.stdout).splitlines()[1:]
def key(l):
    l = re.sub(r'line:\d+:\d+', 'line:L:C', l); l = re.sub(r'endln:\d+:\d+', 'endln:L:C', l)
    l = re.sub(r'\((work@|[a-zA-Z_])[^)]*\)', '(_)', l); l = re.sub(r'file:[^,]*', 'file:_', l)
    l = re.sub(r'\|(UINT|INT|BIN|HEX|DEC|STRING):.*', r'|\1:_', l)
    return l.strip()[:120]
# usage: svtests_firstdiff.py <matrix.csv> <tiers> <out.csv> <workroot>
rows = list(csv.DictReader(open(sys.argv[1])))
tiers = set(sys.argv[2].split(','))
WORKROOT = os.path.abspath(sys.argv[4])
out = csv.writer(open(sys.argv[3], 'w', newline='')); out.writerow(['path', 'tier', 'kind', 'k1', 'k2', 'k3', 'raw1'])
n = 0
for r in rows:
    if r['agreement'] not in ('DIFFERENT', 'JUDGE_EQUAL') or r['tier'] not in tiers: continue
    w = os.path.join(WORKROOT, r['path'][:-3])
    g, o = os.path.join(w, 'slpp_all', 'surelog.uhdm'), os.path.join(w, 'slang.uhdm')
    if not (os.path.exists(g) and os.path.exists(o)):
        out.writerow([r['path'], r['tier'], 'missing', '', '', '', '']); continue
    try:
        a, b = dump(g), dump(o)
    except subprocess.TimeoutExpired:
        out.writerow([r['path'], r['tier'], 'dump-timeout', '', '', '', '']); continue
    d = [l for l in difflib.unified_diff(a, b, n=0, lineterm='') if l[:1] in '-+' and not l.startswith(('---', '+++'))]
    ks = [key(l) for l in d[:3]]
    out.writerow([r['path'], r['tier'], r['agreement']] + ks + [''] * (3 - len(ks)) + [d[0][:160] if d else ''])
    n += 1
    if n % 50 == 0: print(n, flush=True)
print('done', n)
