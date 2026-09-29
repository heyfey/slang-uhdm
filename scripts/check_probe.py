#!/usr/bin/env python3
"""The probe-case regression check: every tests/probe/**/dut.sv is exported by
slang-uhdm (single unit, no builtins) and judged by uhdm-cmp against the
golden the pinned Surelog writes for it. Goldens are not committed: the
first use builds each one with Surelog and stores it in the same golden
cache the corpus sweep uses (~/.cache/slang-uhdm-goldens, GOLDEN_CACHE=
relocates), keyed by Surelog's version line and the case's repo-relative
path, so a Surelog pin bump simply rebuilds them.

Since the strict flip (2026-09-24) a case is EQUAL only when uhdm-cmp reads it
equal AND uhdm-strictcmp reads it STRICT_EQUAL; a case uhdm-cmp reads equal
that the strict comparator does not is STRICT_NOTEQUAL (the strict verdict is
its detail). --out writes `case,status,detail,strict`; tests/sweep.sh compares
it against results/golden_probe.csv with compare_results.py, which fails on a
regression against that baseline. Exit 1 when any case is not judge-equal
(neither EQUAL nor STRICT_NOTEQUAL): every case must stay uhdm-cmp equal.

    check_probe.py [--jobs N] [--filter REGEX] [--workdir DIR] [--out CSV]

Tools resolve as in verify_golden.py (SLANG_UHDM, UHDM_CMP, STRICT_CMP, SURELOG env).
"""
import argparse
import concurrent.futures
import glob
import hashlib
import os
import re
import shutil
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import verify_golden as vg  # noqa: E402

ROOT = os.path.join(vg.REPO_ROOT, 'tests', 'probe')
SL_ARGS = ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv', '-mt', '0', '-mp', '0']
SU_ARGS = ['dut.sv', '--single-unit', '--nobuiltin']


def cases(pattern):
    out = []
    for g in sorted(glob.glob(os.path.join(ROOT, '**', 'dut.sv'), recursive=True)):
        rel = os.path.relpath(os.path.dirname(g), ROOT)
        if pattern and not re.search(pattern, rel):
            continue
        out.append(rel)
    return out


_IDENTITY = None


def cache_dir(rel):
    """Cache key: Surelog's version line + the case's repo-relative path + the
    producer arguments (the same shape as verify_golden.golden_cache_dir) +
    the case's sources: a case edited in place must not be judged against the
    golden of its old text (the corpora are pinned submodules; a case is not)."""
    global _IDENTITY
    if _IDENTITY is None:
        _IDENTITY = vg._surelog_identity()
    src = hashlib.sha1()
    d = os.path.join(ROOT, rel)
    for dp, _dirs, files in sorted(os.walk(d)):
        for fn in sorted(files):
            if fn != 'LAW':
                with open(os.path.join(dp, fn), 'rb') as f:
                    src.update(os.path.relpath(os.path.join(dp, fn), d).encode() + b'\0' + f.read() + b'\0')
    key = hashlib.sha1('\0'.join([_IDENTITY, 'tests/probe/' + rel] + SL_ARGS[:5] + [src.hexdigest()])
                       .encode()).hexdigest()[:20]
    return os.path.join(vg.cache_base(), key)


def golden(rel, workdir, timeout):
    """The cached golden for an case, built with the pinned Surelog on a miss.
    Returns (path or None, detail)."""
    cdir = cache_dir(rel)
    hit = vg.cache_load(cdir)
    if hit and hit[1]:
        return hit[1], ''
    if not os.path.exists(vg.SURELOG):
        return None, f'golden not cached and no producer: {vg.SURELOG} (set $SURELOG)'
    w = os.path.join(workdir, 'gold', rel.replace('/', '__'))
    shutil.rmtree(w, ignore_errors=True)
    os.makedirs(w)
    try:
        subprocess.run([vg.SURELOG] + SL_ARGS + ['-o', w], cwd=os.path.join(ROOT, rel),
                       capture_output=True, text=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        return None, 'surelog timeout'
    got = glob.glob(os.path.join(w, '**', '*.uhdm'), recursive=True)
    if not got:
        return None, 'surelog wrote no database'
    vg.cache_store(cdir, got[0], 'OK|')
    hit = vg.cache_load(cdir)
    return (hit[1] if hit else got[0]), 'built'


def check(rel, workdir, timeout):
    """-> (case, status, detail, strict, golden built now)."""
    d = os.path.join(ROOT, rel)
    g, gdet = golden(rel, workdir, timeout)
    built = gdet == 'built'
    if not g:
        return rel, 'SURELOG_FAIL', gdet, '', built
    out = os.path.join(workdir, rel.replace('/', '__') + '.uhdm')
    # A database left by an earlier run in a reused workdir would be judged
    # in place of a failed export (and -o does not truncate a larger file).
    try:
        os.unlink(out)
    except FileNotFoundError:
        pass
    try:
        su = subprocess.run([vg.SLANG_UHDM] + SU_ARGS + ['-o', out], cwd=d,
                            capture_output=True, text=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        return rel, 'TIMEOUT', 'slang-uhdm', '', built
    # As in verify_golden.py: a rejection is the ABSENCE of the database. An
    # "unsupported constructs" exit (4) with a written database is judged.
    if not os.path.isfile(out) or os.path.getsize(out) == 0:
        return rel, 'SLANG_FAIL', (su.stderr.strip().splitlines() or [f'rc={su.returncode}'])[-1][:120], '', built
    try:
        cp = subprocess.run([vg.UHDM_CMP, g, out],
                            capture_output=True, text=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        return rel, 'TIMEOUT', 'uhdm-cmp', '', built
    if cp.returncode != 0:
        head = (cp.stdout.strip().splitlines() or [''])[0]
        return rel, 'NOT_EQUAL', head[:120], '', built
    # The strict flip: EQUAL needs the strict comparator's equality too.
    strict = vg.strict_verdict(g, out, timeout)
    if strict == 'differ:stage1':   # uhdm-cmp's own Compare rejects the pair
        return rel, 'NOT_EQUAL', 'uhdm-strictcmp stage 1: not equal', '', built
    if strict != 'equal':
        return rel, 'STRICT_NOTEQUAL', strict, strict, built
    return rel, 'EQUAL', '', strict, built


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--jobs', type=int, default=3)
    ap.add_argument('--filter', default=None)
    ap.add_argument('--workdir', default='/tmp/slang-uhdm-probe')
    ap.add_argument('--timeout', type=int, default=120)
    ap.add_argument('--out', default=None,
                    help='write case,status,detail,strict (the golden_probe.csv shape)')
    a = ap.parse_args()
    for env, tool in (('SLANG_UHDM', vg.SLANG_UHDM), ('UHDM_CMP', vg.UHDM_CMP),
                      ('STRICT_CMP', vg.STRICT_CMP)):
        if not os.path.exists(tool):
            sys.exit(f'missing tool: {tool} (set ${env}; see tests/README.md)')
    todo = cases(a.filter)
    os.makedirs(a.workdir, exist_ok=True)
    counts, bad, built, strict, rows = {}, [], 0, {}, []
    with concurrent.futures.ThreadPoolExecutor(max_workers=a.jobs) as pool:
        for rel, st, det, sv, b in pool.map(lambda r: check(r, a.workdir, a.timeout), todo):
            rows.append((rel, st, det, sv))
            counts[st] = counts.get(st, 0) + 1
            built += b
            if sv:
                s = sv.split('(')[0]
                strict[s] = strict.get(s, 0) + 1
            if st not in ('EQUAL', 'STRICT_NOTEQUAL'):
                bad.append((rel, st, det))
    if a.out:
        with open(a.out, 'wt', newline='\n') as f:
            f.write('case,status,detail,strict\n')
            for rel, st, det, sv in rows:
                det = det.replace(',', ';').replace('\n', ' ')
                f.write(f'{rel},{st},{det},{sv}\n')
    for rel, st, det in bad:
        print(f'{st} {rel} {det}')
    print('probe cases: ' + ' '.join(f'{k}={v}' for k, v in sorted(counts.items())) +
          f' (of {len(todo)}); goldens built now={built}, from cache={len(todo) - built}')
    if strict:
        print('probe strict: ' + ' '.join(f'{k}={v}' for k, v in sorted(strict.items(), key=lambda kv: -kv[1])))
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
