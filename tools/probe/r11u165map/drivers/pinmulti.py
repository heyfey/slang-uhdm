#!/usr/bin/env python3
"""r11u138 (r11u142: + db=SAME/DIFF, the gdb run's database vs the reference one): exact site pinning at scale. pinprep2.py + pinall.py pin ONE cluster
per gdb run; this pins every wanted cluster of one example row in ONE gdb run:
the example object's UhdmId (strictcmp_x --dump-ids) gives its creation rank
among its type's objects (objrank); a gdb Python breakpoint on each needed
Serializer::Make<type> counts calls and records the backtrace at the wanted
ranks without stopping. Output is pins.txt-shaped (sites.py reads it).
Example choice: the smallest database (records) among the cluster's rows.
Env PART=i/n splits the rows over n parallel runs.
Args: <work> <repo> <objrank> <strictcmp_x> <g1 exporter> <corpus dumps> <probe dumps> <tmp dir> <out pins> <ids...>"""
import json, sys, os, subprocess, re, collections
W, REPO, OBJRANK, SCX, G1, DUMPS, PDUMPS, TMP, OUTP = sys.argv[1:10]; WANT = set(sys.argv[10:])
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE); sys.path.insert(0, os.path.join(REPO, 'scripts'))
from common import rekey
from analyze import load, parents
import verify_golden as vg
cid = json.load(open(f'{W}/ids.json'))['cid']
jobs = {}
for p in ('jobs_int.tsv', 'probe_ne.tsv'):
    for l in open(f'{W}/{p}'):
        c, m, n, g, o, s = l.rstrip('\n').split('\t'); jobs[(c, m, n)] = (g, o, s)
# r11u142: never dispatch a slang-fenced test (names read from RESUME.md, as redact.py does)
_t = open(os.path.join(REPO, 'RESUME.md')).read()
FENCED = set(re.findall(r'`([A-Za-z_][A-Za-z0-9_]*)`', re.search(r'The four slang-fenced tests(.*?)are NEVER dispatched', _t, re.S).group(1)))
assert len(FENCED) == 4
best = {}
for src, dumps in (('corpus', DUMPS), ('probe', PDUMPS)):
    for l in open(f'{W}/{src}.jsonl'):
        r = json.loads(l)
        if r['test'] in FENCED: continue
        for x in r['rows']:
            k = cid.get(rekey(x))
            if k in WANT:
                pref = (r['nB'], 0 if r['mode'] == 'default' else 1)
                if k not in best or pref < best[k][0]: best[k] = (pref, r, x, dumps)
byrow = collections.defaultdict(list)
for k, (_, r, x, dumps) in best.items(): byrow[(r['corpus'], r['mode'], r['test'], dumps)].append((k, x))
sdirs = {n: v[0] for n, v in vg.discover_surelog(None).items()}
sdirs.update({'u2r:' + n: v[0] for n, v in vg.discover_uhdm2rtlil(None).items()})
os.makedirs(TMP, exist_ok=True)
GDBPY = r'''
import gdb, json, os
W = json.load(open(os.environ['PINMULTI_WANT']))
counts = {}; hits = []
class BP(gdb.Breakpoint):
    def __init__(self, t):
        super().__init__('UHDM::Serializer::Make' + t[0].upper() + t[1:], internal=True); self.t = t
    def stop(self):
        c = counts[self.t] = counts.get(self.t, 0) + 1
        if str(c) in W[self.t]:
            f = gdb.newest_frame(); fr = []; i = 0
            while f is not None and i < 12:
                try:
                    sal = f.find_sal(); fn = sal.symtab.filename if sal.symtab else '?'; ln = sal.line
                except Exception: fn, ln = '?', 0
                fr.append([i, f.name() or '??', fn, ln]); f = f.older(); i += 1
            hits.append([self.t, c, fr])
            json.dump(hits, open(os.environ['PINMULTI_OUT'], 'w'))   # saved per hit: a timeout keeps what was found
        return False
for t in W: BP(t)
def done(ev):
    json.dump(hits, open(os.environ['PINMULTI_OUT'], 'w'))
gdb.events.exited.connect(done)
'''
open(f'{TMP}/pinmulti_gdb.py', 'w').write(GDBPY)
def short(name):
    if 'operator()' in name and 'lambda' in name: return 'operator()'
    n = re.sub(r'<.*>', '', name); n = re.sub(r'\(.*$', '', n)
    n = n.split('::')[-1] or name
    return 'operator()' if n == 'operator' else n
out = open(OUTP, 'w'); nrow = 0
PI, PN = map(int, os.environ.get('PART', '0/1').split('/'))   # PART=i/n: every n-th row from i (parallel runs)
for idx, ((corpus, mode, test, dumps), items) in enumerate(sorted(byrow.items())):
    nrow += 1
    if idx % PN != PI: continue
    D = f'{dumps}/{corpus}/{mode}/{test}'
    g, o, s = jobs[(corpus, mode, test)]
    B = load(D + '.b'); A = None
    tb = f'{TMP}/pm.b'
    subprocess.run([SCX, '--max', '0', '--dump-ids', '--dump-a', f'{TMP}/pm.a', '--dump-b', tb, g, o], capture_output=True)
    lines = open(tb, errors='replace').read().split('\n')
    rk = {}
    for q in subprocess.run([OBJRANK, o], capture_output=True, text=True).stdout.splitlines():
        t = q.split('\t'); rk[(t[0], t[2])] = t[1]
    want = collections.defaultdict(dict); meta = {}
    for k, x in items:
        j = x['ib']; what = 'object'
        if j < 0:
            if A is None: A = load(D + '.a'); pA = parents(A)
            ia = x['ia'] if x['ia'] >= 0 else 0; gp = pA[ia]
            cand = [i for i, q in enumerate(B) if gp >= 0 and q[:14] == A[gp][:14]]
            j = min(cand, key=lambda i: abs(i - gp)) if cand else -1; what = 'holder'
        if j < 0: print(k, 'no partner', file=sys.stderr); continue
        rec = lines[j].split('\t'); ext = rec[14].split('\x1f')
        if rec[:14] != B[j][:14]: print(k, 'dump mismatch', file=sys.stderr); continue
        rank = rk.get((rec[1], ext[4]))
        if not rank: print(k, 'no rank', file=sys.stderr); continue
        want[rec[1]].setdefault(rank, []).append(k)
        meta[k] = f"{corpus}/{mode}/{test} {what} #{j} {rec[1]} '{rec[2]}' {rec[5]} {':'.join(rec[6:10])} id={ext[4]}"
    if not want: continue
    if corpus == 'probe':
        cwd = os.path.join(REPO, 'tests/probe', s); args = ['dut.sv', '--single-unit', '--nobuiltin']
    else:
        cm = open(os.path.join(os.path.dirname(o), 'cmds.txt')).read()
        args = re.search(r'^slang:\s+\S+\s+(.*?)\s+-o\s', cm, re.M).group(1).split()
        cwd = sdirs.get(test if corpus == 'surelog' else 'u2r:' + test, '?')
    json.dump(want, open(f'{TMP}/want.json', 'w'))
    env = dict(os.environ, PINMULTI_WANT=f'{TMP}/want.json', PINMULTI_OUT=f'{TMP}/hits.json')
    if os.path.exists(f'{TMP}/hits.json'): os.unlink(f'{TMP}/hits.json')
    ob = f'{TMP}/pm_out.uhdm'
    if os.path.exists(ob): os.unlink(ob)
    subprocess.run(['timeout', '1800', 'gdb', '-q', '-batch', '-ex', 'set pagination off', '-ex', f'source {TMP}/pinmulti_gdb.py',
                    '-ex', 'run', '--args', G1] + args + ['-o', ob], cwd=cwd, env=env, capture_output=True)
    hits = json.load(open(f'{TMP}/hits.json')) if os.path.exists(f'{TMP}/hits.json') else []
    # r11u142: the ranks are valid only if the gdb run wrote the reference database byte for byte
    same = os.path.exists(ob) and open(ob, 'rb').read() == open(o, 'rb').read()
    got = {(t, str(c)): fr for t, c, fr in hits}
    for t, rs in want.items():
        for r, ks in rs.items():
            for k in ks:
                out.write(f"== {k} {meta[k]} db={'SAME' if same else 'DIFF'}\n  rank {r}:\n")
                for i, name, fn, ln in got.get((t, r), []):
                    out.write(f'    #{i} {short(name)} at {fn}:{ln}\n')
    out.flush()
    print(f'row {nrow}/{len(byrow)} {corpus}/{mode}/{test}: {sum(len(v) for v in want.values())} ranks, {len(hits)} hits', flush=True)
