#!/usr/bin/env python3
"""Downstream gate: slang-uhdm's database must drive uhdm2rtlil (the Yosys
UHDM frontend) to the SAME result as Surelog's database, on every corpus test
except the ones slang-uhdm rejects.

Per test (third_party/uhdm2rtlil/test/<name>) two lanes run the flow of
uhdm2rtlil's own test_uhdm_workflow.sh:
  surelog lane   uhdm2rtlil's Surelog writes the database (its flags:
                 -parse -nobuiltin -nocache -DSYNTHESIS -filterprotected
                 -d vpi_ids -d uhdm), cached in the golden cache;
  slang lane     slang-uhdm writes it from the translated command line.
Both go through the same Yosys + plugin script (read_uhdm, RTLIL before
hierarchy, hierarchy/proc/opt, RTLIL, synth, gate-level netlist). Verdicts:
  IDENTICAL      same status and byte-identical RTLIL (both) and netlist
  EQUIVALENT     texts differ but uhdm2rtlil's test_equivalence.sh proves the
                 netlists equivalent (gold = surelog lane, gate = slang lane)
  DIVERGENT      texts differ and equivalence fails or cannot be checked
  SLANG_REJECT   slang-uhdm wrote no database (the allowed exception)
  SURELOG_FAIL   Surelog wrote no database (no reference; skipped)
  STATUS_DIFF    the two lanes' Yosys statuses differ (OK/NO_GATES/READ_FAIL/
                 CRASH/TIMEOUT)
Exit 1 when any row is not IDENTICAL or SLANG_REJECT, unless --baseline names a
CSV whose row for that test carries the same verdict (a reviewed exception).

    downstream_uhdm2rtlil.py --out CSV [--jobs N] [--filter RE] [--workdir DIR]
                             [--baseline results/downstream_uhdm2rtlil.csv]
Locations resolve from the repo (UHDM2RTLIL_ROOT, YOSYS, UHDM2RTLIL_PLUGIN,
UHDM2RTLIL_SURELOG, SLANG_UHDM override).
"""
import argparse
import concurrent.futures
import csv
import glob
import hashlib
import os
import shutil
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import verify_golden as vg  # noqa: E402

U2R = os.environ.get('UHDM2RTLIL_ROOT') or os.path.join(vg.REPO_ROOT, 'third_party', 'uhdm2rtlil')
YOSYS = vg._tool('YOSYS', os.path.join(U2R, 'out', 'current', 'bin', 'yosys'), shutil.which('yosys'))
PLUGIN = os.environ.get('UHDM2RTLIL_PLUGIN') or os.path.join(U2R, 'build', 'uhdm2rtlil.so')
U2R_SURELOG = vg._tool('UHDM2RTLIL_SURELOG',
                       os.path.join(U2R, 'build', 'third_party', 'Surelog', 'bin', 'surelog'))
EQUIV = os.path.join(U2R, 'test', 'test_equivalence.sh')
DOWNSTREAM_FLAGS = ['-DSYNTHESIS', '-filterprotected', '-d', 'vpi_ids', '-d', 'uhdm']
STATUSES_JUDGED = ('OK', 'NO_GATES')


def surelog_identity():
    out = subprocess.run([U2R_SURELOG, '--version'], capture_output=True, text=True).stdout
    ver = next((l.split(':', 1)[1].strip() for l in out.splitlines() if l.startswith('VERSION')), '?')
    src = os.path.join(U2R, 'third_party', 'Surelog')
    rev = subprocess.run(['git', '-C', src, 'rev-parse', '--short', 'HEAD'],
                         capture_output=True, text=True).stdout.strip()
    return f'surelog {ver} @{rev}'


_ID = None


def surelog_db(dirpath, sl_args, work, timeout):
    """Surelog's database for the test, from the golden cache or built now."""
    global _ID
    if _ID is None:
        _ID = surelog_identity()
    parts = [_ID, vg._portable(dirpath)] + [vg._portable(a) for a in sl_args]
    if vg._reaches_outside(sl_args):
        parts.append(os.path.abspath(dirpath))
    cdir = os.path.join(vg.CACHE_ROOT, hashlib.sha1('\0'.join(parts).encode()).hexdigest()[:20])
    hit = vg.cache_load(cdir)
    if hit and hit[1]:
        return hit[1]
    w = os.path.join(work, 'surelog_out')
    shutil.rmtree(w, ignore_errors=True)
    os.makedirs(w)
    try:
        subprocess.run([U2R_SURELOG] + sl_args + ['-mt', '0', '-mp', '0', '-o', w], cwd=dirpath,
                       capture_output=True, text=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        return None
    got = vg.find_uhdm(w)
    if not got:
        return None
    vg.cache_store(cdir, got[0], 'OK|')
    hit = vg.cache_load(cdir)
    return hit[1] if hit and hit[1] else got[0]


def slang_db(dirpath, su_args, work, timeout):
    out = os.path.join(work, 'slang.uhdm')
    try:
        subprocess.run([vg.SLANG_UHDM] + su_args + ['-o', out], cwd=dirpath,
                       capture_output=True, text=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        return None
    return out if os.path.isfile(out) and os.path.getsize(out) > 0 else None


def gate_count(path):
    try:
        with open(path, errors='replace') as f:
            return sum(1 for l in f if '$_' in l)
    except OSError:
        return 0


def yosys_lane(name, lane, db, top, formal, work, timeout):
    """Run uhdm2rtlil's flow on one database. Returns (status, gates, files).

    The plugin iterates pointer-keyed maps, so its output can depend on heap
    layout, which the LENGTH of the paths it sees can shift (measured: a
    verdict flipped with the work directory's name length alone). Yosys
    therefore runs in a scratch directory whose path length is fixed, on a
    copy of the database named in.uhdm, writing fixed file names; the results
    are then moved into the work directory."""
    d = os.path.join(work, lane)
    shutil.rmtree(d, ignore_errors=True)
    os.makedirs(d)
    run = '/tmp/u2rds-' + hashlib.sha1(f'{name}/{lane}'.encode()).hexdigest()[:12]
    shutil.rmtree(run, ignore_errors=True)
    os.makedirs(run)
    shutil.copy(db, os.path.join(run, 'in.uhdm'))
    hier = f'-top {top}' if top else '-auto-top'
    flag = '-formal ' if formal else ''
    script = (f'plugin -i {PLUGIN}\nread_uhdm {flag}in.uhdm\nwrite_rtlil nohier.il\n'
              f'hierarchy -check {hier}\nproc\nopt\nwrite_rtlil post.il\n'
              f'synth {hier}\nwrite_verilog -noexpr synth.v\n')
    with open(os.path.join(run, 'run.ys'), 'w') as f:
        f.write(script)
    files = {k: os.path.join(d, f'{name}{s}') for k, s in
             (('nohier', '_nohier.il'), ('il', '.il'), ('synth', '_synth.v'))}
    try:
        r = subprocess.run([YOSYS, '-q', 'run.ys'], cwd=run, capture_output=True, text=True,
                           timeout=timeout)
    except subprocess.TimeoutExpired:
        shutil.rmtree(run, ignore_errors=True)
        return 'TIMEOUT', 0, files
    for src, key in (('nohier.il', 'nohier'), ('post.il', 'il'), ('synth.v', 'synth')):
        if os.path.isfile(os.path.join(run, src)):
            shutil.move(os.path.join(run, src), files[key])
    shutil.copy(os.path.join(run, 'run.ys'), os.path.join(d, 'run.ys'))
    shutil.rmtree(run, ignore_errors=True)
    with open(os.path.join(d, 'yosys.log'), 'w') as f:
        f.write(r.stdout + r.stderr)
    if r.returncode < 0 or r.returncode >= 128:
        return 'CRASH', 0, files
    if r.returncode != 0 or not os.path.isfile(files['synth']):
        return 'READ_FAIL', 0, files
    g = gate_count(files['synth'])
    return ('OK' if g > 0 else 'NO_GATES'), g, files


def clean_netlist(path):
    out = []
    with open(path, errors='replace') as f:
        for l in f:
            s = l.strip()
            if s and not s.startswith('//'):
                out.append(s)
    return '\n'.join(out)


def same(a, b, key):
    try:
        if key == 'synth':
            return clean_netlist(a) == clean_netlist(b)
        with open(a, 'rb') as fa, open(b, 'rb') as fb:
            return fa.read() == fb.read()
    except OSError:
        return False


def equivalence(name, dirpath, sf, gf, work):
    """uhdm2rtlil's test_equivalence.sh: gold = surelog lane, gate = slang lane."""
    stage = os.path.join(work, 'equiv', name)
    shutil.rmtree(stage, ignore_errors=True)
    os.makedirs(stage)
    shutil.copy(sf['synth'], os.path.join(stage, f'{name}_from_verilog_synth.v'))
    shutil.copy(gf['synth'], os.path.join(stage, f'{name}_from_uhdm_synth.v'))
    for k, src in (('nohier', sf['nohier']),):
        shutil.copy(src, os.path.join(stage, f'{name}_from_verilog_nohier.il'))
    shutil.copy(gf['nohier'], os.path.join(stage, f'{name}_from_uhdm_nohier.il'))
    pf = os.path.join(dirpath, 'project.f')
    if os.path.isfile(pf):
        shutil.copy(pf, stage)
    try:
        r = subprocess.run(['bash', EQUIV, stage], cwd=os.path.dirname(stage),
                           capture_output=True, text=True, timeout=900)
    except subprocess.TimeoutExpired:
        return False, 'equivalence timeout'
    with open(os.path.join(stage, 'equiv.log'), 'w') as f:
        f.write(r.stdout + r.stderr)
    tail = (r.stdout.strip().splitlines() or [''])[-1]
    return r.returncode == 0, tail[:120]


def one(name, dirpath, parts, workroot, timeout):
    work = os.path.join(workroot, name)
    os.makedirs(work, exist_ok=True)
    rest = [p for p in parts if p not in ('-parse', '-nobuiltin', '-nocache')]
    sl_args = ['-parse', '-nobuiltin', '-nocache'] + DOWNSTREAM_FLAGS + rest
    su_args, blocking, nodb, nobuiltin = vg.translate(sl_args)
    if nobuiltin:
        su_args.append('--nobuiltin')
    top = None
    if '-top' in parts:
        top = parts[parts.index('-top') + 1]
    formal = False
    pf = os.path.join(dirpath, 'project.f')
    if os.path.isfile(pf):
        with open(pf) as f:
            formal = any(l.strip().lower().replace(' ', '').startswith('#formal:1') for l in f)
    row = {'name': name, 'verdict': '', 'surelog_status': '', 'slang_status': '',
           'surelog_gates': '', 'slang_gates': '', 'differs': '', 'detail': ''}
    sdb = surelog_db(dirpath, sl_args, work, timeout)
    if not sdb:
        row.update(verdict='SURELOG_FAIL', detail='no reference database')
        return row
    gdb = slang_db(dirpath, su_args, work, timeout)
    if not gdb:
        row.update(verdict='SLANG_REJECT')
        return row
    ss, sg, sf = yosys_lane(name, 'surelog', sdb, top, formal, work, timeout)
    gs, gg, gf = yosys_lane(name, 'slanguh', gdb, top, formal, work, timeout)
    row.update(surelog_status=ss, slang_status=gs, surelog_gates=sg, slang_gates=gg)
    if ss != gs:
        row.update(verdict='STATUS_DIFF')
        return row
    if ss not in STATUSES_JUDGED:
        row.update(verdict='IDENTICAL', detail=f'both {ss}')
        return row
    diff = [k for k in ('nohier', 'il', 'synth') if not same(sf[k], gf[k], k)]
    row['differs'] = ' '.join(diff)
    if not diff:
        row.update(verdict='IDENTICAL')
        return row
    ok, det = equivalence(name, dirpath, sf, gf, work)
    row.update(verdict='EQUIVALENT' if ok else 'DIVERGENT', detail=det.replace(',', ';'))
    return row


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', required=True)
    ap.add_argument('--jobs', type=int, default=3)
    ap.add_argument('--filter', default=None)
    ap.add_argument('--workdir', default='/tmp/slang-uhdm-downstream')
    ap.add_argument('--timeout', type=int, default=300)
    ap.add_argument('--baseline', default=None)
    a = ap.parse_args()
    for env, tool in (('YOSYS', YOSYS), ('UHDM2RTLIL_PLUGIN', PLUGIN),
                      ('UHDM2RTLIL_SURELOG', U2R_SURELOG), ('SLANG_UHDM', vg.SLANG_UHDM)):
        if not os.path.exists(tool):
            sys.exit(f'missing tool: {tool} (set ${env}; build third_party/uhdm2rtlil, '
                     f'see tests/README.md)')
    tests = vg.discover_uhdm2rtlil(a.filter)
    print(f'{len(tests)} uhdm2rtlil tests; yosys={YOSYS}', flush=True)
    os.makedirs(a.workdir, exist_ok=True)
    rows = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=a.jobs) as pool:
        futs = {pool.submit(one, n, d, p, a.workdir, a.timeout): n for n, (d, p) in tests.items()}
        for i, fu in enumerate(concurrent.futures.as_completed(futs), 1):
            try:
                rows.append(fu.result())
            except Exception as e:  # noqa: BLE001
                rows.append({'name': futs[fu], 'verdict': 'HARNESS_ERROR', 'surelog_status': '',
                             'slang_status': '', 'surelog_gates': '', 'slang_gates': '',
                             'differs': '', 'detail': str(e)[:120].replace(',', ';')})
            if i % 50 == 0:
                print(f'  {i}/{len(tests)}', flush=True)
    rows.sort(key=lambda r: r['name'].lower())
    with open(a.out, 'w', newline='') as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()) if rows else ['name', 'verdict'])
        w.writeheader()
        w.writerows(rows)
    base = {}
    if a.baseline and os.path.isfile(a.baseline):
        with open(a.baseline, newline='') as f:
            base = {r['name']: r['verdict'] for r in csv.DictReader(f)}
    counts, bad = {}, []
    for r in rows:
        counts[r['verdict']] = counts.get(r['verdict'], 0) + 1
        ok = r['verdict'] in ('IDENTICAL', 'SLANG_REJECT') or base.get(r['name']) == r['verdict']
        if not ok:
            bad.append(r)
    for r in bad:
        print(f"{r['verdict']} {r['name']} surelog={r['surelog_status']} slang={r['slang_status']} "
              f"differs=[{r['differs']}] {r['detail']}")
    print('downstream: ' + ' '.join(f'{k}={v}' for k, v in sorted(counts.items())) +
          f' (of {len(rows)}); not identical and not excused={len(bad)}')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
