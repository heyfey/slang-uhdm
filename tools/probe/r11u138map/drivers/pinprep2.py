#!/usr/bin/env python3
"""r11u132 exact site pinning prep. For each cluster id: the smallest example
(probe/uhdm2rtlil first, default mode first), OUR object at walk index j (or,
for a golden-only object, our HOLDER: the record of ours equal to golden's
parent, nearest by walk index), re-dumped with `strictcmp_x --dump-ids` so the
record carries its UhdmId, whose rank among its type's objects (objrank) is the
call count of Serializer::Make<type> that minted it. (r11u128map's pinprep
matched by type/name/file/span, which is ambiguous for unlocated objects such
as ref_typespec.) Output lines are pinall.py's input.
Args: <work> <repo> <objrank> <strictcmp_x> <corpus dumps> <probe dumps> <tmp dir> <ids...>"""
import json, sys, os, subprocess, re
W, REPO, OBJRANK, SCX, DUMPS, PDUMPS, TMP = sys.argv[1:8]; WANT = set(sys.argv[8:])
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
for src, dumps in (('corpus', DUMPS), ('probe', PDUMPS)):
    for l in open(f'{W}/{src}.jsonl'):
        r = json.loads(l)
        for x in r['rows']:
            k = cid.get(rekey(x))
            if k in WANT:
                pref = (0 if r['corpus'] != 'surelog' else 1, 0 if r['mode'] == 'default' else 1, r['nB'])
                if k not in best or pref < best[k][0]: best[k] = (pref, r, x, dumps)
sdirs = {n: v[0] for n, v in vg.discover_surelog(None).items()}
sdirs.update({'u2r:' + n: v[0] for n, v in vg.discover_uhdm2rtlil(None).items()})
os.makedirs(TMP, exist_ok=True)
rankcache = {}
for k in sorted(WANT):
    if k not in best: print(k, 'NO EXAMPLE', file=sys.stderr); continue
    _, r, x, dumps = best[k]
    D = f"{dumps}/{r['corpus']}/{r['mode']}/{r['test']}"
    g, o, s = jobs[(r['corpus'], r['mode'], r['test'])]
    j = x['ib']; what = 'object'
    B = load(D + '.b')
    if j < 0:
        A = load(D + '.a'); pA = parents(A); ia = x['ia'] if x['ia'] >= 0 else 0; gp = pA[ia]
        cand = [i for i, q in enumerate(B) if gp >= 0 and q[:14] == A[gp][:14]]
        j = min(cand, key=lambda i: abs(i - gp)) if cand else -1; what = 'holder'
    if j < 0: print(k, 'no partner', file=sys.stderr); continue
    tb = f'{TMP}/{k}.b'
    subprocess.run([SCX, '--max', '0', '--dump-ids', '--dump-a', f'{TMP}/{k}.a', '--dump-b', tb, g, o], capture_output=True)
    lines = open(tb, errors='replace').read().split('\n')
    rec = lines[j].split('\t'); ext = rec[14].split('\x1f')
    assert rec[:14] == B[j][:14], (k, 'dump mismatch')
    oid = ext[4]
    if o not in rankcache:
        rk = {}
        for q in subprocess.run([OBJRANK, o], capture_output=True, text=True).stdout.splitlines():
            t = q.split('\t'); rk[(t[0], t[2])] = t[1]
        rankcache.clear(); rankcache[o] = rk
    rank = rankcache[o].get((rec[1], oid))
    os.unlink(tb); os.unlink(f'{TMP}/{k}.a')
    if r['corpus'] == 'probe':
        cwd = os.path.join(REPO, 'tests/probe', s); args = ['dut.sv', '--single-unit', '--nobuiltin']
    else:
        cm = open(os.path.join(os.path.dirname(o), 'cmds.txt')).read()
        args = re.search(r'^slang:\s+\S+\s+(.*?)\s+-o\s', cm, re.M).group(1).split()
        cwd = sdirs.get(r['test'] if r['corpus'] == 'surelog' else 'u2r:' + r['test'], '?')
    mk = 'Make' + rec[1][0].upper() + rec[1][1:]
    print(f"{k}\t{r['corpus']}/{r['mode']}/{r['test']}\t{what} #{j} {rec[1]} '{rec[2]}' {rec[5]} {':'.join(rec[6:10])} id={oid}\tranks={[rank] if rank else []}\tcwd={cwd}\tmk={mk}\targs={' '.join(args)}", flush=True)
