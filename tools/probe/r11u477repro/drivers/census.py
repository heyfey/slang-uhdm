#!/usr/bin/env python3
"""census.py <binA> <binB> <outdir> <jobs>: run both binaries (B traced through
R11U477_TRACE) on the slang side of every fence-filtered row-mode of the probe,
surelog (default + testflags), uhdm2rtlil (default + testflags) and downstream
lanes, from the rows' own directories; print rc and md5 per binary.  No Surelog run."""
import os, sys, subprocess, hashlib, concurrent.futures as cf
sys.path.insert(0, '/tmp/wt_r11u477/scripts')
import verify_golden as vg
import downstream_uhdm2rtlil as ds
A, B, OUT, J = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])
for b in (A, B):
    assert os.access(b, os.X_OK), b
fence = [l.strip() for l in open('/tmp/r11u477_fenced.txt') if l.strip()]
def fenced(s): return any(f in s for f in fence)
jobs = []
PROBE = '/tmp/wt_r11u477/tests/probe'
for root, dirs, files in os.walk(PROBE):
    if 'dut.sv' in files:
        rel = os.path.relpath(root, PROBE)
        jobs.append(('probe', rel, root, ['dut.sv', '--single-unit', '--nobuiltin']))
for corpus, disc in (('surelog', vg.discover_surelog), ('uhdm2rtlil', vg.discover_uhdm2rtlil)):
    for name, (dirpath, parts) in disc(None).items():
        if fenced(name) or fenced(dirpath):
            continue
        if name in vg.DEFERRED_TESTS:
            continue
        sources, _ = vg.split_sources(parts)
        loc, sl_only = vg.location_args(parts)
        su_mode = ['--sverilog'] if '-sverilog' in sl_only else []
        su = su_mode + [vg.LOCATION_RENAME.get(a, a) for a in loc] + list(sources) + ['--single-unit']
        jobs.append((corpus + '.d', name, dirpath, su))
        su_args, blocking, nodb, nobuiltin = vg.translate(parts)
        if not blocking and not nodb:
            if nobuiltin: su_args = su_args + ['--nobuiltin']
            jobs.append((corpus + '.t', name, dirpath, su_args))
        if corpus == 'uhdm2rtlil':
            rest = [p for p in parts if p not in ('-parse', '-nobuiltin', '-nocache')]
            sl_args = ['-parse', '-nobuiltin', '-nocache'] + ds.DOWNSTREAM_FLAGS + rest
            su2, bl2, nd2, nb2 = vg.translate(sl_args)
            if nb2: su2 = su2 + ['--nobuiltin']
            jobs.append(('downstream', name, dirpath, su2))
SVT = '/home/heyfey/git-repos/sv-tests'
if os.environ.get('CENSUS_SVTESTS', '1') == '1':
    sys.path.insert(0, '/tmp/wt_r11u477/scripts/svtests')
    import json, csv
    import svtests_matrix as sm
    libs = json.load(open(os.path.join(SVT, 'conf', 'runners', 'libs.json')))
    d = '/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/UVM/1800.2-2017-1.0'
    libs['uvm'] = {'files': [os.path.join(d, 'src', 'uvm_pkg.sv')], 'incdirs': [os.path.join(d, 'src')]}
    for r in csv.DictReader(open('/tmp/wt_r11u477/results/golden_svtests.csv')):
        rel = r['case']
        if fenced(rel): continue
        sv = os.path.join(SVT, 'tests', rel)
        params = sm.parse_metadata(sv)
        sm.apply_libs(params, libs, os.path.join(SVT, 'third_party'))
        tags = params['tags']
        sverilog = any(t in tags for t in ('black-parrot', 'basejump', 'ivtest'))
        args = (['--sverilog'] if sverilog else [])
        top = params['top_module'].strip()
        if top: args += ['--top', top]
        args += ['-D' + x for x in params['defines']] + ['-I' + x for x in params['incdirs']] + params['files'] + ['--single-unit']
        wd = os.path.join(OUT, 'svwork', rel[:-3]); os.makedirs(wd, exist_ok=True)
        jobs.append(('svtests', rel, wd, args))
os.makedirs(OUT, exist_ok=True)
def run(job):
    lane, name, d, args = job
    res = []
    for tag, b in (('A', A), ('B', B)):
        o = os.path.join(OUT, 'db', lane, name.replace('/', '__') + '.' + tag + '.uhdm')
        os.makedirs(os.path.dirname(o), exist_ok=True)
        if os.path.exists(o): os.remove(o)
        env = dict(os.environ)
        env.pop('R11U477_TRACE', None)
        if tag == 'B':
            td = os.path.join(OUT, 'trace', lane, name.replace('/', '__'))
            os.makedirs(td, exist_ok=True)
            env['R11U477_TRACE'] = td
        try:
            r = subprocess.run([b] + args + ['-o', o], cwd=d, env=env, stdout=subprocess.DEVNULL,
                               stderr=subprocess.DEVNULL, timeout=300).returncode
        except subprocess.TimeoutExpired:
            r = 'TO'
        h = hashlib.md5(open(o, 'rb').read()).hexdigest()[:10] if os.path.exists(o) else '-'
        res += [str(r), h]
    return f"{lane}\t{name}\t" + '\t'.join(res)
with cf.ThreadPoolExecutor(J) as ex, open(os.path.join(OUT, 'census.tsv'), 'w') as f:
    for line in ex.map(run, jobs):
        f.write(line + '\n'); f.flush()
print(len(jobs))
