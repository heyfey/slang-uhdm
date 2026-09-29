#!/usr/bin/env python3
"""r11u230map: pin the WRITER of each wanted cluster's differing field (map 14's audit: a mint pin is not the field's
writer when a later pass stamps the field). One gdb run of the -g1 exporter per cluster on its example database (the
smallest database carrying the cluster with an ours-side record; a probe case when there is one):
  1. the example record's UhdmId (strictcmp_x --dump-ids) gives its creation rank among its type (objrank);
  2. a breakpoint on UHDM::Serializer::Make<Type> with ignore count rank-1 stops at the mint; the backtrace there is
     the MINT; `finish` returns the object's address;
  3. the differing field is then watched until the process exits, each write recorded with its backtrace:
     span  -> hardware watchpoints on vpiLineNo_ (4 bytes) and vpiEndLineNo_+vpiColumnNo_+vpiEndColumnNo_ (8 bytes)
     file  -> a breakpoint on UHDM::BaseClass::VpiFile(string_view) conditioned on this == the object
     name / value / decompile -> the out-of-line setters of the object's class chain, conditioned the same way
     fullname -> the class's VpiFullName setter when it has one, plus a hardware watchpoint on vpiParent_ (UHDM
              synthesizes a full name from the parent chain when none is stored: the uhdm dump's rule)
     depth -> a hardware watchpoint on vpiParent_
  4. the WRITER is the last recorded write (for fullname: the last setter call when one stored a name, else the last
     parent write); no write recorded = the field keeps the mint's value (the writer is the mint).
The gdb run must write the reference database byte for byte (db=SAME) for the rank to be the example object.
struct / order clusters have no field: their pin is the mint (pinmulti.py, map 14's sites) and they are skipped here.
Fence: a slang-fenced test is never an example (common.fenced(), fail closed).
Args: <work W> <repo (the tree whose tests/probe paths the reference databases embed)> <objrank> <strictcmp_x> <g1 exporter>
      <corpus dumps> <probe dumps> <tmp dir> <out.jsonl> <offsets file (fieldoff output)> <cluster ids...>
Env PART=i/n splits the clusters over n parallel runs; PW_TIMEOUT (seconds, default 1500); PW_PREFER=corpus takes the
example from the corpus rows only (the second pin of a cluster whose smallest example is a probe case); PW_ROWS="corpus/mode/test ..."
takes the earliest record of the cluster in one of those row-modes (with a single row: the row's head record)."""
import json, sys, os, subprocess, re, collections, glob
W, REPO, OBJRANK, SCX, G1, DUMPS, PDUMPS, TMP, OUTP, OFFS = sys.argv[1:11]; WANT = sys.argv[11:]
for t in (OBJRANK, SCX, G1):
    if not os.access(t, os.X_OK): raise SystemExit(f'pinwriter: {t} is not executable: refusing to run')
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE); sys.path.insert(0, os.path.join(REPO, 'scripts'))
from common import rekey, fenced
import verify_golden as vg
FENCED = fenced()
OFF = dict(l.split() for l in open(OFFS)); OFF = {k: int(v) for k, v in OFF.items()}
ids = json.load(open(f'{W}/ids.json')); cid = ids['cid']; KEY = ids['key']
jobs = {}
for p in ('jobs_int.tsv', 'probejobs.tsv'):
    for l in open(f'{W}/{p}'):
        c, m, n, g, o, s = l.rstrip('\n').split('\t'); jobs[(c, m, n)] = (g, o, s)
# the class chain of every UHDM type (headers), and the out-of-line setters (libuhdm.a)
INC = os.path.expanduser('~/.local/include/uhdm')
BASE = {}
for h in glob.glob(f'{INC}/*.h'):
    for m in re.finditer(r'^class (\w+)(?: final)? : public (\w+)', open(h, errors='replace').read(), re.M): BASE[m.group(1)] = m.group(2)
nm = subprocess.run(['nm', '-C', os.path.expanduser('~/.local/lib64/libuhdm.a')], capture_output=True, text=True).stdout
SETTERS = collections.defaultdict(set)
for m in re.finditer(r' [TW] UHDM::(\w+)::(Vpi\w+)\(std::basic_string_view<char, std::char_traits<char> >\)$', nm, re.M):
    SETTERS[m.group(1)].add(m.group(2))
def setter(t, f):
    c = t
    while c:
        if f in SETTERS.get(c, ()): return f"UHDM::{c}::{f}(std::basic_string_view<char, std::char_traits<char> >)"
        c = BASE.get(c)
    return None
def make(t): return 'UHDM::Serializer::Make' + t[0].upper() + t[1:]
# examples: the smallest database with an ours-side record of the cluster
best = {}
SRCS = (('corpus', DUMPS),) if os.environ.get('PW_PREFER') == 'corpus' or os.environ.get('PW_ROWS') else (('corpus', DUMPS), ('probe', PDUMPS))
# PW_ROWS="corpus/mode/test ..." restricts the examples to those row-modes (the earliest record of the cluster there):
# the HEAD record of a row when the cluster is the row's first
ROWS = {tuple(x.split('/')) for x in os.environ.get('PW_ROWS', '').split()}
for src, dumps in SRCS:
    for l in open(f'{W}/{src}.jsonl'):
        r = json.loads(l)
        if any(re.search(r'(?<![A-Za-z0-9_])' + re.escape(f) + r'(?![A-Za-z0-9_])', r['test']) for f in FENCED): continue
        if ROWS and (r['corpus'], r['mode'], r['test']) not in ROWS: continue
        for x in r['rows']:
            k = cid.get(rekey(x))
            if k not in WANT or x['ib'] < 0 or x['facet'] in ('struct', 'order'): continue
            pref = (x['ib'],) if ROWS else (r['nB'], 0 if r['mode'] == 'default' else 1, x['ib'])
            if k not in best or pref < best[k][0]: best[k] = (pref, r, x, dumps)
sdirs = {n: v[0] for n, v in vg.discover_surelog(None).items()}
sdirs.update({'u2r:' + n: v[0] for n, v in vg.discover_uhdm2rtlil(None).items()})
os.makedirs(TMP, exist_ok=True)
GDBPY = r'''
import gdb, json, os
P = json.load(open(os.environ['PW_SPEC'])); OUT = os.environ['PW_OUT']
out = dict(mint=None, ptr=None, hits=[], nhits=0, err=None, exited=False)
def save(): json.dump(out, open(OUT, 'w'))
def bt(n=10):
    f = gdb.newest_frame(); fr = []; i = 0
    while f is not None and i < n:
        try:
            sal = f.find_sal(); fn = sal.symtab.filename if sal.symtab else '?'; ln = sal.line
        except Exception: fn, ln = '?', 0
        fr.append([i, f.name() or '??', fn, ln]); f = f.older(); i += 1
    return fr
def rd(ptr):
    inf = gdb.selected_inferior()
    try:
        b = bytes(inf.read_memory(ptr + P['off']['vpiParent_'], 8)); par = int.from_bytes(b, 'little')
        b = bytes(inf.read_memory(ptr + P['off']['vpiLineNo_'], 12))
        return dict(parent=hex(par), line=int.from_bytes(b[0:4], 'little'), endline=int.from_bytes(b[4:8], 'little'),
                    col=int.from_bytes(b[8:10], 'little'), endcol=int.from_bytes(b[10:12], 'little'))
    except Exception as e: return dict(err=str(e))
try:
    mk = gdb.Breakpoint(P['make'], internal=True)
    if P['rank'] > 1: mk.ignore_count = P['rank'] - 1
    gdb.execute('run', to_string=True)
    out['mint'] = bt(); mk.delete()
    gdb.execute('finish', to_string=True)
    ptr = int(gdb.parse_and_eval('$rax')) & 0xffffffffffffffff
    out['ptr'] = hex(ptr); save()
    bps = {}
    for s in P['setters']:
        b = gdb.Breakpoint(s, internal=True); b.condition = f'$rdi == {ptr}'; bps[b.number] = 'setter ' + s.split('(')[0]
    for name, off, ln in P['watch']:
        typ = {4: 'unsigned int', 8: 'unsigned long'}[ln]
        b = gdb.Breakpoint(f'*({typ}*){ptr + off}', gdb.BP_WATCHPOINT, gdb.WP_WRITE, internal=True); bps[b.number] = 'watch ' + name
    while True:
        gdb.execute('continue', to_string=True)
        if gdb.selected_inferior().pid == 0: out['exited'] = True; break
        out['nhits'] += 1
        h = dict(bt=bt(), after=rd(ptr))
        if len(out['hits']) >= 40: out['hits'].pop(5)
        out['hits'].append(h)
        if out['nhits'] > 100000: out['err'] = 'hit cap'; break
except Exception as e:
    out['err'] = repr(e)
save()
'''
open(f'{TMP}/pinwriter_gdb.py', 'w').write(GDBPY)
PI, PN = map(int, os.environ.get('PART', '0/1').split('/'))
idcache = {}; rkcache = {}
out = open(OUTP, 'a')
for idx, k in enumerate(sorted(best)):
    if idx % PN != PI: continue
    _, r, x, dumps = best[k]
    corpus, mode, test = r['corpus'], r['mode'], r['test']
    g, o, s = jobs[(corpus, mode, test)]
    if o not in idcache:
        tb = f'{TMP}/pw_{PI}.b'
        subprocess.run([SCX, '--max', '0', '--dump-ids', '--dump-a', f'{TMP}/pw_{PI}.a', '--dump-b', tb, g, o], capture_output=True)
        idcache.clear(); idcache[o] = open(tb, errors='replace').read().split('\n')
        rkcache.clear()
        for q in subprocess.run([OBJRANK, o], capture_output=True, text=True).stdout.splitlines():
            t = q.split('\t'); rkcache[(t[0], t[2])] = int(t[1])
    lines = idcache[o]; j = x['ib']
    rec = lines[j].split('\t'); ext = rec[14].split('\x1f')
    typ = rec[1]; oid = ext[4]; rank = rkcache.get((typ, oid))
    res = dict(cluster=k, key=KEY[k], facet=x['facet'], fields=x['fields'], example=f"{corpus}/{mode}/{test}", rec=j, type=typ,
               name=rec[2], golden=x['golden'], ours=x['ours'], id=oid, rank=rank)
    if rank is None: res['err'] = 'no rank'; out.write(json.dumps(res) + '\n'); out.flush(); continue
    fc = x['facet']; st = []; wa = []
    if fc == 'span': wa = [('line', OFF['vpiLineNo_'], 4), ('endline+col+endcol', OFF['vpiEndLineNo_'], 8)]
    elif fc == 'file': st = [setter('BaseClass', 'VpiFile') or 'UHDM::BaseClass::VpiFile(std::basic_string_view<char, std::char_traits<char> >)']
    elif fc == 'name': st = [s_ for s_ in (setter(typ, 'VpiName'), setter(typ, 'VpiDefName')) if s_]
    elif fc == 'value': st = [s_ for s_ in (setter(typ, 'VpiValue'), setter(typ, 'VpiDecompile')) if s_]
    elif fc == 'fullname':
        s_ = setter(typ, 'VpiFullName'); st = [s_] if s_ else []; wa = [('parent', OFF['vpiParent_'], 8)]
    elif fc == 'depth': wa = [('parent', OFF['vpiParent_'], 8)]
    spec = dict(make=make(typ), rank=rank, setters=st, watch=wa, off=OFF)
    json.dump(spec, open(f'{TMP}/pw_spec_{PI}.json', 'w'))
    if corpus == 'probe':
        cwd = os.path.join(REPO, 'tests/probe', s); args = ['dut.sv', '--single-unit', '--nobuiltin']
    else:
        cm = open(os.path.join(os.path.dirname(o), 'cmds.txt')).read()
        args = re.search(r'^slang:\s+\S+\s+(.*?)\s+-o\s', cm, re.M).group(1).split()
        cwd = sdirs.get(test if corpus == 'surelog' else 'u2r:' + test, '?')
    ob = f'{TMP}/pw_out_{PI}.uhdm'; po = f'{TMP}/pw_res_{PI}.json'
    for f in (ob, po):
        if os.path.exists(f): os.unlink(f)
    env = dict(os.environ, PW_SPEC=f'{TMP}/pw_spec_{PI}.json', PW_OUT=po)
    p = subprocess.run(['timeout', os.environ.get('PW_TIMEOUT', '1500'), 'gdb', '-q', '-batch', '-ex', 'set pagination off', '-ex', 'set confirm off',
                        '-ex', f'source {TMP}/pinwriter_gdb.py', '--args', G1] + args + ['-o', ob], cwd=cwd, env=env, capture_output=True, text=True)
    res['gdb_rc'] = p.returncode
    res['db'] = 'SAME' if os.path.exists(ob) and open(ob, 'rb').read() == open(o, 'rb').read() else 'DIFF'
    res['spec'] = dict(setters=[q.split('(')[0] for q in st], watch=[w[0] for w in wa])
    if os.path.exists(po): res.update(json.load(open(po)))
    else: res['err'] = 'no gdb output: ' + p.stderr[-300:]
    out.write(json.dumps(res) + '\n'); out.flush()
    print(f"{idx+1}/{len(best)} {k} {res['example']} {typ} rank={rank} hits={res.get('nhits')} db={res['db']} err={res.get('err')}", flush=True)
