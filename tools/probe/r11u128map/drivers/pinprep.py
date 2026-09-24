#!/usr/bin/env python3
"""For each cluster id: the smallest example whose OUR object exists (or, for a
golden-only object, its holder), its database, the object's creation rank per
type (objrank), and the pinsite.sh command. Args: <work> <repo> <objrank bin> <ids...>"""
import json, sys, os, subprocess, re
W, REPO, OBJRANK = sys.argv[1:4]; WANT = set(sys.argv[4:])
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
from common import rekey
from analyze import load, parents
import verify_golden as vg
ids = json.load(open(f'{W}/ids.json')); cid = ids['cid']
jobs = {}
for p in ('jobs_int.tsv', 'probe_ne.tsv'):
    for l in open(f'{W}/{p}'):
        c, m, n, g, o, s = l.rstrip('\n').split('\t'); jobs[(c, m, n)] = (g, o, s)
best = {}
for src, dumps in (('corpus', '/tmp/r11u128_dumps'), ('probe', '/tmp/r11u128_pdumps')):
    for l in open(f'{W}/{src}.jsonl'):
        r = json.loads(l)
        for x in r['rows']:
            k = cid.get(rekey(x))
            if k in WANT:
                pref = (0 if r['corpus'] != 'surelog' else 1, 0 if r['mode'] == 'default' else 1, r['nB'])
                if k not in best or pref < best[k][0]:
                    best[k] = (pref, r, x, dumps)
sdirs = {n: v[0] for n, v in vg.discover_surelog(None).items()}
sdirs.update({'u2r:' + n: v[0] for n, v in vg.discover_uhdm2rtlil(None).items()})
for k in sorted(WANT):
    if k not in best: print(k, 'NO EXAMPLE'); continue
    _, r, x, dumps = best[k]
    D = f"{dumps}/{r['corpus']}/{r['mode']}/{r['test']}"
    B = load(D + '.b'); pB = parents(B)
    j = x['ib']; what = 'object'
    if j < 0:
        # golden-only: pin our holder (the partner of the golden holder is not known; use the
        # ours record at the same index as the golden parent when it matches)
        A = load(D + '.a'); pA = parents(A); gp = pA[x['ia']]
        cand = [i for i, q in enumerate(B) if q[1:] == A[gp][1:]]
        j = cand[0] if cand else -1; what = 'holder'
    if j < 0: print(k, 'no partner'); continue
    rec = B[j]
    g, o, s = jobs[(r['corpus'], r['mode'], r['test'])]
    ls = subprocess.run([OBJRANK, o], capture_output=True, text=True).stdout.splitlines()
    span = ':'.join(rec[6:10])
    hits = [q.split('\t') for q in ls if q.split('\t')[0] == rec[1] and q.split('\t')[3] == rec[2]
            and q.split('\t')[4] == rec[5] and q.split('\t')[5] == span]
    if r['corpus'] == 'probe':
        cwd = os.path.join(REPO, 'tests/probe', s); args = ['dut.sv', '--single-unit', '--nobuiltin']
    else:
        cm = open(os.path.join(os.path.dirname(o), 'cmds.txt')).read()
        a = re.search(r'^slang:\s+\S+\s+(.*?)\s+-o\s', cm, re.M).group(1).split()
        args = a
        cwd = sdirs.get(r['test'] if r['corpus'] == 'surelog' else 'u2r:' + r['test'], '?')
    mk = 'Make' + rec[1][0].upper() + rec[1][1:]
    print(f"{k}\t{r['corpus']}/{r['mode']}/{r['test']}\t{what} #{j} {rec[1]} '{rec[2]}' {rec[5]} {span}\tranks={[h[1] for h in hits]}\tcwd={cwd}\tmk={mk}\targs={' '.join(args)}")
