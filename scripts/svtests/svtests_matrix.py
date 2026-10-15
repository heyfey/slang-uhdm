#!/usr/bin/env python3
"""sv-tests agreement matrix: slang-uhdm against Surelog on chipsalliance/sv-tests.

For every tests/**/*.sv in an sv-tests checkout:
  1. parse the test header (:name: :tags: :type: :files: :incdirs: :defines:
     :top_module: :timeout: :should_fail_because:), with the defaults of
     sv-tests' tools/runner, and the libs.json injection (the `uvm` tag
     prepends third_party/tests/uvm/src/uvm_pkg.sv and its incdir);
  2. run Surelog with sv-tests' own tools/runners/Surelog.py recipe
     (-nopython -parse -nonote -noinfo -nowarning, -sverilog for the
     black-parrot/basejump/ivtest tags, -lowmem for black-parrot/rsd,
     --top-module, -D, -I, files) MINUS `-noelab`: a -noelab database is
     unelaborated and never comparable with an exporter output, so parsing
     and preprocessing tests are run elaborated like the others; plus
     `-mt 0 -mp 0 -o <work>` as scripts/verify_golden.py does;
  3. run slang-uhdm on the same sources (-I, -D, --top, --sverilog when
     Surelog got -sverilog, --single-unit as Surelog's default compilation
     unit, -o <work>/slang.uhdm);
  4. compare with uhdm-cmp, then uhdm-strictcmp (the strict gate of
     tests/sweep.sh), and classify the agreement.

Classes (column `agreement`):
  IDENTICAL        both accept, uhdm-cmp equal AND uhdm-strictcmp STRICT_EQUAL
  JUDGE_EQUAL      both accept, uhdm-cmp equal, strict comparator differs
  DIFFERENT        both accept, uhdm-cmp not equal
  BOTH_REJECT      neither tool produced an accepted database
  SLANG_ONLY       slang-uhdm accepted, Surelog rejected (or wrote no db)
  SURELOG_ONLY     Surelog accepted, slang-uhdm rejected
  SLANG_CRASH      slang-uhdm died on a signal
  SURELOG_CRASH    Surelog died on a signal
  TIMEOUT          one side timed out

"accept" for Surelog is sv-tests' own criterion (rc & 0x07 == 0, i.e. no
syntax/fatal/error) plus a database on disk; for slang-uhdm an output file
and rc 0.
"""
import argparse, csv, hashlib, json, os, re, shlex, signal, subprocess, sys, time
from concurrent.futures import ProcessPoolExecutor, as_completed

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.environ.get('SLANG_UHDM_REPO') or os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import verify_golden as vg  # noqa: E402  (tool discovery + strict_verdict)

SUPPORTED = ['name', 'tags', 'description', 'files', 'incdirs', 'top_module', 'timeout',
             'type', 'should_fail', 'should_fail_because', 'defines',
             'compatible-runners', 'unsynthesizable', 'results_group', 'simvariants']


def parse_metadata(sv_path):
    params = {}
    with open(sv_path, errors='replace') as f:
        for line in f:
            m = re.search(r'^:([a-zA-Z_-]+):\s*(.+)', line)
            if not m:
                continue
            key = m.group(1).lower()
            if key in SUPPORTED or re.match(r'runner_.*_flags$', key):
                params[key] = m.group(2).strip()
            if len(set(SUPPORTED) - set(params)) == 0:
                break
    params.setdefault('name', sv_path)
    params.setdefault('files', sv_path)
    params.setdefault('incdirs', os.path.dirname(sv_path))
    params.setdefault('top_module', '')
    params.setdefault('timeout', '30')
    params.setdefault('type', 'parsing elaboration')
    params.setdefault('should_fail_because', '')
    params.setdefault('should_fail', '1' if params['should_fail_because'] else '0')
    params.setdefault('defines', '')
    params.setdefault('tags', '')
    params['files'] = params['files'].split()
    params['incdirs'] = params['incdirs'].split()
    params['defines'] = params['defines'].split()
    return params


def apply_libs(params, libs, third_party):
    for key, val in libs.items():
        if key in params['tags']:
            params['files'] = [os.path.abspath(os.path.join(third_party, p))
                               for p in val.get('files', [])] + params['files']
            params['incdirs'] = [os.path.abspath(os.path.join(third_party, p))
                                 for p in val.get('incdirs', [])] + params['incdirs']


def get_mode(params):
    feats = params['type'].split()
    for m in ('simulation', 'simulation_without_run', 'elaboration', 'parsing', 'preprocessing'):
        if m in feats:
            return m
    return 'parsing'


def tier_of(params, svtests):
    if any('/third_party/cores/' in f for f in params['files']):
        return 'cores'
    if re.search(r'\buvm\b', params['tags']):
        return 'uvm'
    return 'plain'


def surelog_cmd(params, work):
    tags = params['tags']
    cmd = [vg.SURELOG, '-nopython', '-parse', '-nonote', '-noinfo', '-nowarning']
    sverilog = any(t in tags for t in ('black-parrot', 'basejump', 'ivtest'))
    if sverilog:
        cmd.append('-sverilog')
    if 'black-parrot' in tags or 'rsd' in tags:
        cmd.append('-lowmem')
    top = params['top_module'].strip()
    if top:
        cmd += ['--top-module', top]
    cmd += ['-D' + d for d in params['defines']]
    cmd += ['-I' + i for i in params['incdirs']]
    cmd += params['files']
    # Surelog serves uvm_pkg.sv from its bundled precompiled package unless told
    # not to; that package carries the include paths of the tree it was built
    # from, so the comparison would read two different UVM sources.
    cmd += vg.precompiled_guard(params['files'])
    cmd += ['-mt', '0', '-mp', '0', '-o', work]
    return cmd, sverilog


def slang_cmd(params, sverilog, out):
    cmd = [vg.SLANG_UHDM]
    if sverilog:
        cmd.append('--sverilog')
    top = params['top_module'].strip()
    if top:
        cmd += ['--top', top]
    cmd += ['-D' + d for d in params['defines']]
    cmd += ['-I' + i for i in params['incdirs']]
    cmd += params['files']
    cmd += ['--single-unit', '-o', out]
    return cmd


def run(cmd, cwd, log, timeout):
    t0 = time.monotonic()
    with open(log, 'wb') as lf:
        lf.write((shlex.join(cmd) + '\n').encode())
        lf.flush()
        try:
            p = subprocess.run(cmd, cwd=cwd, stdout=lf, stderr=subprocess.STDOUT, timeout=timeout)
            rc = p.returncode
        except subprocess.TimeoutExpired:
            rc = 'TIMEOUT'
    return rc, round(time.monotonic() - t0, 1)


def first_error(log):
    try:
        lines = open(log, errors='replace').read().splitlines()[1:]
    except OSError:
        return ''
    for l in lines:
        if 'error' in l.lower():
            return l.strip()[:160]
    return (lines[-1].strip()[:160] if lines else '')


def one(task):
    sv_path, rel, params, workroot, timeout_cap, keep_golden = task
    work = os.path.join(workroot, rel[:-3])
    os.makedirs(work, exist_ok=True)
    meta_timeout = int(params.get('timeout', '30') or 30)
    timeout = min(max(meta_timeout, 120), timeout_cap)
    row = dict(name=params['name'], path=rel, tier=tier_of(params, None),
               mode=get_mode(params), tags=params['tags'],
               should_fail=params['should_fail'], timeout=timeout)

    # Surelog
    sl_work = work   # Surelog's -o is slang's output dir too, as scripts/verify_golden.py lays it out
    for sub in ('slpp_all', 'slpp_unit'):
        subprocess.run(['rm', '-rf', os.path.join(sl_work, sub)])
    cmd, sverilog = surelog_cmd(params, sl_work)
    rc, secs = run(cmd, sl_work, os.path.join(work, 'surelog.log'), timeout)
    dbs = vg.find_uhdm(sl_work)
    row['surelog_rc'] = rc
    row['surelog_s'] = secs
    if rc == 'TIMEOUT':
        sl_st = 'TIMEOUT'
    elif isinstance(rc, int) and rc < 0:
        sl_st = 'CRASH'
    elif dbs and (rc & 0x07) == 0:
        sl_st = 'OK'
    elif dbs:
        sl_st = 'DB_WITH_ERRORS'
    else:
        sl_st = 'FAIL'
    row['surelog'] = sl_st
    row['surelog_msg'] = '' if sl_st == 'OK' else first_error(os.path.join(work, 'surelog.log'))

    # slang-uhdm
    out = os.path.join(work, 'slang.uhdm')
    try:
        os.unlink(out)
    except FileNotFoundError:
        pass
    cmd = slang_cmd(params, sverilog, out)
    rc, secs = run(cmd, work, os.path.join(work, 'slang.log'), timeout)
    row['slang_rc'] = rc
    row['slang_s'] = secs
    if rc == 'TIMEOUT':
        su_st = 'TIMEOUT'
    elif isinstance(rc, int) and rc < 0:
        su_st = 'CRASH'
    elif os.path.exists(out) and rc == 0:
        su_st = 'OK'
    elif os.path.exists(out):
        su_st = 'DB_WITH_ERRORS'
    else:
        su_st = 'REJECT'
    row['slang'] = su_st
    row['slang_msg'] = '' if su_st == 'OK' else first_error(os.path.join(work, 'slang.log'))

    # compare
    cmp_st, strict = '', ''
    if sl_st == 'OK' and su_st == 'OK':
        try:
            cp = subprocess.run([vg.UHDM_CMP, dbs[0], out], capture_output=True, text=True, timeout=timeout)
            if cp.returncode != 0:
                cmp_st = 'NOTEQUAL'
                tail = (cp.stdout or cp.stderr or '').strip().splitlines()
                strict = (tail[0][:120] if tail else '')
            else:
                strict = vg.strict_verdict(dbs[0], out, timeout)
                if strict == 'differ:stage1':
                    cmp_st = 'NOTEQUAL'
                elif strict == 'equal':
                    cmp_st = 'EQUAL'
                else:
                    cmp_st = 'JUDGE_EQUAL'
        except subprocess.TimeoutExpired:
            cmp_st = 'TIMEOUT'
    row['cmp'] = cmp_st
    row['strict'] = strict

    # agreement
    if 'TIMEOUT' in (sl_st, su_st, cmp_st):
        ag = 'TIMEOUT'
    elif su_st == 'CRASH':
        ag = 'SLANG_CRASH'
    elif sl_st == 'CRASH':
        ag = 'SURELOG_CRASH'
    elif sl_st == 'OK' and su_st == 'OK':
        ag = {'EQUAL': 'IDENTICAL', 'JUDGE_EQUAL': 'JUDGE_EQUAL', 'NOTEQUAL': 'DIFFERENT'}[cmp_st]
    elif sl_st == 'OK':
        ag = 'SURELOG_ONLY'
    elif su_st == 'OK':
        ag = 'SLANG_ONLY'
    else:
        ag = 'BOTH_REJECT'
    row['agreement'] = ag
    # expectation cross-check: should_fail tests are expected to be rejected
    exp = params['should_fail'] == '1'
    row['slang_vs_expect'] = ('ok' if (su_st != 'OK') == exp else 'mismatch')
    row['surelog_vs_expect'] = ('ok' if (sl_st != 'OK') == exp else 'mismatch')
    # keep the disk small: drop the golden unless asked to keep it on a non-identical
    # row, drop our database on identical rows; logs stay
    if ag == 'IDENTICAL' or not keep_golden:
        for sub in ('slpp_all', 'slpp_unit'):
            subprocess.run(['rm', '-rf', os.path.join(sl_work, sub)])
    if os.path.exists(out) and ag == 'IDENTICAL':
        os.unlink(out)
    return row


COLS = ['name', 'path', 'tier', 'mode', 'tags', 'should_fail', 'timeout',
        'surelog', 'surelog_rc', 'surelog_s', 'surelog_msg',
        'slang', 'slang_rc', 'slang_s', 'slang_msg',
        'cmp', 'strict', 'agreement', 'slang_vs_expect', 'surelog_vs_expect']


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--svtests', required=True, help='sv-tests checkout')
    ap.add_argument('--out', required=True, help='csv path (appended; rows present are skipped)')
    ap.add_argument('--workroot', required=True)
    ap.add_argument('--jobs', type=int, default=4)
    ap.add_argument('--tier', default='all', help='plain|uvm|cores|all (comma list)')
    ap.add_argument('--match', default='', help='regex on the relative path')
    ap.add_argument('--exclude-regex', default='', help='tests whose path, name, tags or files match are skipped')
    ap.add_argument('--timeout-cap', type=int, default=1200)
    ap.add_argument('--limit', type=int, default=0)
    ap.add_argument('--uvm-dir', default='', help='use this UVM tree (its src/uvm_pkg.sv and src/) for the uvm tag instead of libs.json, for both tools')
    ap.add_argument('--paths-file', default='', help='only the relative paths listed in this file (one per line)')
    ap.add_argument('--keep-golden', action='store_true', help='keep slpp_all/surelog.uhdm on non-identical rows')
    a = ap.parse_args()

    svtests = os.path.abspath(a.svtests)
    tests_dir = os.path.join(svtests, 'tests')
    third_party = os.path.join(svtests, 'third_party')
    with open(os.path.join(svtests, 'conf', 'runners', 'libs.json')) as f:
        libs = json.load(f)
    if a.uvm_dir:
        d = os.path.abspath(a.uvm_dir)
        libs['uvm'] = {'files': [os.path.join(d, 'src', 'uvm_pkg.sv')], 'incdirs': [os.path.join(d, 'src')]}
    tiers = set(a.tier.split(','))
    excl = re.compile(a.exclude_regex, re.I) if a.exclude_regex else None

    only = None
    if a.paths_file:
        only = set(l.strip() for l in open(a.paths_file) if l.strip())
    done = set()
    if os.path.exists(a.out):
        with open(a.out, newline='') as f:
            for r in csv.DictReader(f):
                done.add(r['path'])

    tasks = []
    skipped_fence = 0
    for dirpath, _d, files in sorted(os.walk(tests_dir)):
        for fn in sorted(files):
            if not fn.endswith('.sv'):
                continue
            sv = os.path.join(dirpath, fn)
            rel = os.path.relpath(sv, tests_dir)
            if a.match and not re.search(a.match, rel):
                continue
            if rel in done or (only is not None and rel not in only):
                continue
            params = parse_metadata(sv)
            apply_libs(params, libs, third_party)
            if excl and excl.search(' '.join([rel, params['name'], params['tags']] + params['files'])):
                skipped_fence += 1
                continue
            if 'all' not in tiers and tier_of(params, svtests) not in tiers:
                continue
            tasks.append((sv, rel, params, a.workroot, a.timeout_cap, a.keep_golden))
            if a.limit and len(tasks) >= a.limit:
                break
        if a.limit and len(tasks) >= a.limit:
            break
    print(f'{len(tasks)} tests to run, {len(done)} already in csv, {skipped_fence} excluded by regex, jobs={a.jobs}', flush=True)

    fresh = not os.path.exists(a.out)
    os.makedirs(os.path.dirname(os.path.abspath(a.out)), exist_ok=True)
    counts = {}
    with open(a.out, 'at', newline='') as cf:
        w = csv.DictWriter(cf, fieldnames=COLS)
        if fresh:
            w.writeheader()
        with ProcessPoolExecutor(max_workers=a.jobs) as ex:
            futs = [ex.submit(one, t) for t in tasks]
            for i, fut in enumerate(as_completed(futs), 1):
                row = fut.result()
                w.writerow({k: row.get(k, '') for k in COLS})
                cf.flush()
                counts[row['agreement']] = counts.get(row['agreement'], 0) + 1
                if i % 50 == 0 or i == len(tasks):
                    print(f'[{i}/{len(tasks)}] ' + ' '.join(f'{k}={v}' for k, v in sorted(counts.items())), flush=True)
    print('done', flush=True)


if __name__ == '__main__':
    main()
