#!/usr/bin/env python3
"""Decode the DIFFERENT rows of an sv-tests matrix csv: rerun Surelog with the
same recipe, run uhdm-cmp, and record the first differing object pair.

uhdm-cmp prints, on the first mismatch, `LHS:` followed by the golden object's
dump and `RHS:` followed by ours.  The cluster key is the object type of each
side plus the first dump line that differs once ids are stripped.
"""
import argparse, csv, os, re, subprocess, sys
from concurrent.futures import ProcessPoolExecutor, as_completed

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import svtests_matrix as sm  # noqa: E402
vg = sm.vg


def norm(line):
    line = re.sub(r'\bid:\d+', 'id:_', line)
    return line.rstrip()


def decode(task):
    rel, params, workroot, timeout = task
    work = os.path.join(workroot, rel[:-3])
    out = os.path.join(work, 'slang.uhdm')
    row = dict(path=rel, tier=sm.tier_of(params, None))
    if not os.path.exists(out):
        row['head'] = 'no slang.uhdm kept'
        return row
    sl_work = work   # the same layout as the matrix run: Surelog -o <work>
    dbs = vg.find_uhdm(sl_work)
    if not dbs:
        cmd, _sv = sm.surelog_cmd(params, sl_work)
        try:
            subprocess.run(cmd, cwd=sl_work, capture_output=True, timeout=timeout)
        except subprocess.TimeoutExpired:
            row['head'] = 'surelog timeout'
            return row
        dbs = vg.find_uhdm(sl_work)
    if not dbs:
        row['head'] = 'surelog wrote no db on rerun'
        return row
    try:
        cp = subprocess.run([vg.UHDM_CMP, dbs[0], out], capture_output=True, text=True, timeout=timeout)
        txt = cp.stdout + cp.stderr
    except subprocess.TimeoutExpired:
        txt = ''
    lines = txt.splitlines()
    # uhdm-cmp prints the golden object where Compare failed, then (when the
    # mismatch is inside a child) `LHS:` and `RHS:` blocks with both sides.
    if 'LHS:' in lines and 'RHS:' in lines:
        l = lines.index('LHS:')
        r = lines.index('RHS:')
        lhs = lines[l + 1:r]
        rhs = lines[r + 1:]
    else:
        blk = []
        for ln in lines:
            if not ln.strip() and blk:
                break
            blk.append(ln)
        lhs, rhs = blk, []
        row['oneblock'] = '1'
    # the object line follows the 'decompile:' label (and its text) on each side
    def objline(block):
        for ln in block:
            m = re.match(r'^([a-z_]+): \((.*?)\), id:', ln)
            if m:
                return m.group(1), m.group(2)
            m = re.match(r'^([a-z_]+): , id:', ln)
            if m:
                return m.group(1), ''
        return ('?', '')
    lt, ln_ = objline(lhs)
    rt, rn_ = objline(rhs)
    diff = ''
    if not rhs:
        # one block: the golden object; the first value line after the object
        first_val = next((norm(x) for x in lhs if x.startswith('|') and not x.startswith('|vpiParent')), '')
        diff = 'ONEBLOCK ' + first_val[:100]
    for a, b in zip(lhs, rhs):
        if norm(a) != norm(b):
            diff = norm(a)[:100] + ' <> ' + norm(b)[:100]
            break
    if not diff and len(lhs) != len(rhs):
        diff = 'length %d <> %d' % (len(lhs), len(rhs))
    row['lhs_type'] = lt
    row['rhs_type'] = rt
    row['lhs_name'] = ln_[:60]
    row['head'] = diff
    row['lhs_first'] = (lhs[1] if len(lhs) > 1 else '')[:120]
    return row


COLS = ['path', 'tier', 'lhs_type', 'rhs_type', 'lhs_name', 'head', 'lhs_first', 'oneblock']


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--svtests', required=True)
    ap.add_argument('--csv', required=True, nargs='+')
    ap.add_argument('--workroot', required=True)
    ap.add_argument('--out', required=True)
    ap.add_argument('--jobs', type=int, default=4)
    ap.add_argument('--timeout', type=int, default=600)
    ap.add_argument('--classes', default='DIFFERENT')
    a = ap.parse_args()
    svtests = os.path.abspath(a.svtests)
    tests_dir = os.path.join(svtests, 'tests')
    third_party = os.path.join(svtests, 'third_party')
    import json
    with open(os.path.join(svtests, 'conf', 'runners', 'libs.json')) as f:
        libs = json.load(f)
    classes = set(a.classes.split(','))
    tasks = []
    for c in a.csv:
        for r in csv.DictReader(open(c, newline='')):
            if r['agreement'] in classes:
                sv = os.path.join(tests_dir, r['path'])
                params = sm.parse_metadata(sv)
                sm.apply_libs(params, libs, third_party)
                tasks.append((r['path'], params, a.workroot, a.timeout))
    print(len(tasks), 'rows to decode', flush=True)
    with open(a.out, 'wt', newline='') as f:
        w = csv.DictWriter(f, fieldnames=COLS)
        w.writeheader()
        with ProcessPoolExecutor(max_workers=a.jobs) as ex:
            futs = [ex.submit(decode, t) for t in tasks]
            for i, fut in enumerate(as_completed(futs), 1):
                row = fut.result()
                w.writerow({k: row.get(k, '') for k in COLS})
                f.flush()
                if i % 50 == 0 or i == len(tasks):
                    print(f'[{i}/{len(tasks)}]', flush=True)
    print('done', flush=True)


if __name__ == '__main__':
    main()
