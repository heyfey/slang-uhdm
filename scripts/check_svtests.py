#!/usr/bin/env python3
"""The sv-tests stage of tests/sweep.sh: every test listed in
results/golden_svtests.csv is run through scripts/svtests/svtests_matrix.py
(Surelog with sv-tests' own recipe, the golden served from the shared golden
cache after its first build; slang-uhdm on the same sources; uhdm-cmp then
uhdm-strictcmp) and the fresh verdicts are compared against that baseline.

The baseline's shape is `case,status,detail,strict` like golden_probe.csv:
  status  EQUAL            both accept, uhdm-cmp equal AND STRICT_EQUAL
          STRICT_NOTEQUAL  both accept, uhdm-cmp equal, strict verdict in `strict`
          DIFFERENT        both accept, uhdm-cmp not equal
          SLANG_ONLY       slang-uhdm accepts, Surelog does not
          SURELOG_ONLY     Surelog accepts, slang-uhdm does not
          BOTH_REJECT      neither accepts
          SLANG_CRASH / SURELOG_CRASH / TIMEOUT

The campaign's two goals (user 2026-10-15) order the statuses:
  (1) what slang accepts, slang-uhdm must accept: a row leaving an accepting
      status (EQUAL, STRICT_NOTEQUAL, DIFFERENT, SLANG_ONLY) for SURELOG_ONLY,
      BOTH_REJECT or SLANG_CRASH is a REGRESSION;
  (2) both-accepted pairs converge: EQUAL > STRICT_NOTEQUAL > DIFFERENT; a
      step down is a REGRESSION, a step up a CONVERSION.
Any other move (a Surelog-side change, a TIMEOUT either way) is a CHANGE and
is printed; a baseline row the run did not produce is a regression.  --write
promotes the fresh verdicts into the baseline (a landing's promotion step).
Exit 1 on any regression.

    check_svtests.py [--jobs N] [--workdir DIR] [--out CSV] [--svtests DIR]
                     [--baseline CSV] [--filter REGEX] [--write]
"""
import argparse
import csv
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..'))
RUNNER = os.path.join(HERE, 'svtests', 'svtests_matrix.py')
UVM_DIR = os.path.join(REPO, 'third_party', 'Surelog', 'third_party', 'UVM', '1800.2-2017-1.0')

RANK = {'EQUAL': 5, 'STRICT_NOTEQUAL': 4, 'DIFFERENT': 3, 'SLANG_ONLY': 3,
        'SURELOG_ONLY': 1, 'BOTH_REJECT': 1, 'SURELOG_CRASH': 1, 'SLANG_CRASH': 0, 'TIMEOUT': -1}
ACCEPTING = {'EQUAL', 'STRICT_NOTEQUAL', 'DIFFERENT', 'SLANG_ONLY'}


def to_status(row):
    ag = row['agreement']
    if ag == 'IDENTICAL':
        return 'EQUAL', '', row['strict']
    if ag == 'JUDGE_EQUAL':
        return 'STRICT_NOTEQUAL', row['strict'], row['strict']
    det = row['slang_msg'] if ag in ('SURELOG_ONLY', 'BOTH_REJECT', 'SLANG_CRASH') else row['surelog_msg']
    if ag == 'DIFFERENT':
        det = row['strict']
    return ag, det, ''


def read_baseline(path):
    base = {}
    with open(path, newline='') as f:
        for r in csv.DictReader(f):
            base[r['case']] = r
    return base


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--jobs', type=int, default=3)
    ap.add_argument('--workdir', default='/tmp/slang-uhdm-svtests')
    ap.add_argument('--out', default=None)
    ap.add_argument('--svtests', default=os.environ.get('SVTESTS_ROOT', os.path.join(os.path.dirname(REPO), 'sv-tests')))
    ap.add_argument('--baseline', default=os.path.join(REPO, 'results', 'golden_svtests.csv'))
    ap.add_argument('--filter', default=None)
    ap.add_argument('--write', action='store_true', help='promote the fresh verdicts into the baseline')
    a = ap.parse_args()
    if not os.path.isdir(os.path.join(a.svtests, 'tests')):
        sys.exit(f'sv-tests checkout not found at {a.svtests} (set SVTESTS_ROOT)')
    base = read_baseline(a.baseline)
    todo = [c for c in base if not a.filter or re.search(a.filter, c)]
    os.makedirs(a.workdir, exist_ok=True)
    lst = os.path.join(a.workdir, 'paths.lst')
    with open(lst, 'wt') as f:
        f.write('\n'.join(todo) + '\n')
    raw = os.path.join(a.workdir, 'matrix.csv')
    if os.path.exists(raw):
        os.unlink(raw)
    cmd = [sys.executable, RUNNER, '--svtests', a.svtests, '--out', raw, '--workroot', os.path.join(a.workdir, 'work'),
           '--jobs', str(a.jobs), '--paths-file', lst, '--uvm-dir', UVM_DIR, '--keep-golden']
    env = dict(os.environ, SLANG_UHDM_REPO=REPO)
    r = subprocess.run(cmd, env=env)
    if r.returncode != 0 or not os.path.exists(raw):
        sys.exit('svtests_matrix.py failed (rc=%s)' % r.returncode)
    fresh = {}
    with open(raw, newline='') as f:
        for row in csv.DictReader(f):
            st, det, sv = to_status(row)
            fresh[row['path']] = (st, det.replace(',', ';').replace('\n', ' ')[:160], sv)
    if a.out:
        with open(a.out, 'wt', newline='\n') as f:
            f.write('case,status,detail,strict\n')
            for c in todo:
                st, det, sv = fresh.get(c, ('MISSING', 'not run', ''))
                f.write(f'{c},{st},{det},{sv}\n')
    regressions, conversions, changes = [], [], []
    counts = {}
    for c in todo:
        old = base[c]['status']
        st, det, sv = fresh.get(c, ('MISSING', 'not run', ''))
        counts[st] = counts.get(st, 0) + 1
        if st == 'MISSING':
            regressions.append((c, old, st, det)); continue
        if st == old:
            if st == 'STRICT_NOTEQUAL' and sv != base[c]['strict']:
                changes.append((c, old + ' ' + base[c]['strict'], st + ' ' + sv))
            continue
        if old in ACCEPTING and st not in ACCEPTING and st != 'TIMEOUT':
            regressions.append((c, old, st, det)); continue
        ro, rn = RANK.get(old, 1), RANK.get(st, 1)
        if st == 'TIMEOUT' or old == 'TIMEOUT':
            changes.append((c, old, st)); continue
        if rn < ro:
            regressions.append((c, old, st, det))
        elif rn > ro and st in ('EQUAL', 'STRICT_NOTEQUAL', 'DIFFERENT', 'SLANG_ONLY'):
            conversions.append((c, old, st))
        else:
            changes.append((c, old, st))
    for c, old, st, det in regressions:
        print(f'REGRESSION {c}: {old} -> {st} {det}')
    for c, old, st in conversions:
        print(f'CONVERSION {c}: {old} -> {st}')
    for c, old, st in changes:
        print(f'CHANGE {c}: {old} -> {st}')
    print('sv-tests: ' + ' '.join(f'{k}={v}' for k, v in sorted(counts.items())) + f' (of {len(todo)})')
    print(f'regressions={len(regressions)} conversions={len(conversions)} changes={len(changes)}')
    if a.write and not regressions:
        rows = []
        with open(a.baseline, newline='') as f:
            for r in csv.DictReader(f):
                if r['case'] in fresh:
                    st, det, sv = fresh[r['case']]
                    r = dict(r, status=st, detail=det, strict=sv)
                rows.append(r)
        with open(a.baseline, 'wt', newline='\n') as f:
            f.write('case,status,detail,strict\n')
            for r in rows:
                f.write(f"{r['case']},{r['status']},{r['detail']},{r['strict']}\n")
        print(f'baseline written: {a.baseline}')
    sys.exit(1 if regressions else 0)


if __name__ == '__main__':
    main()
