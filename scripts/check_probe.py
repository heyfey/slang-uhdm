#!/usr/bin/env python3
"""The probe-case regression check: every tests/probe/**/dut.sv is exported by
slang-uhdm (single unit, no builtins) and judged by uhdm-cmp against the
golden the pinned Surelog writes for it. Goldens are not committed: the
first use builds each one with Surelog and stores it in the same golden
cache the corpus sweep uses (~/.cache/slang-uhdm-goldens, GOLDEN_CACHE=
relocates), keyed by Surelog's version line and the case's repo-relative
path, so a Surelog pin bump simply rebuilds them. Every case must judge
EQUAL; exit 1 otherwise.

    check_probe.py [--jobs N] [--filter REGEX] [--workdir DIR]

Tools resolve as in verify_golden.py (SLANG_UHDM, UHDM_CMP, SURELOG env).
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
    producer arguments (the same shape as verify_golden.golden_cache_dir)."""
    global _IDENTITY
    if _IDENTITY is None:
        _IDENTITY = vg._surelog_identity()
    key = hashlib.sha1('\0'.join([_IDENTITY, 'tests/probe/' + rel] + SL_ARGS[:5])
                       .encode()).hexdigest()[:20]
    return os.path.join(vg.CACHE_ROOT, key)


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
    d = os.path.join(ROOT, rel)
    g, gdet = golden(rel, workdir, timeout)
    if not g:
        return rel, 'SURELOG_FAIL', gdet
    out = os.path.join(workdir, rel.replace('/', '__') + '.uhdm')
    try:
        su = subprocess.run([vg.SLANG_UHDM] + SU_ARGS + ['-o', out], cwd=d,
                            capture_output=True, text=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        return rel, 'TIMEOUT', 'slang-uhdm'
    # As in verify_golden.py: a rejection is the ABSENCE of the database. An
    # "unsupported constructs" exit (4) with a written database is judged.
    if not os.path.isfile(out) or os.path.getsize(out) == 0:
        return rel, 'SLANG_FAIL', (su.stderr.strip().splitlines() or [f'rc={su.returncode}'])[-1][:120]
    try:
        cp = subprocess.run([vg.UHDM_CMP, g, out],
                            capture_output=True, text=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        return rel, 'TIMEOUT', 'uhdm-cmp'
    if cp.returncode != 0:
        head = (cp.stdout.strip().splitlines() or [''])[0]
        return rel, 'NOT_EQUAL', head[:120]
    # Measurement only (not the verdict yet): the strict comparator's field.
    strict = vg.strict_verdict(g, out, timeout) if os.path.exists(vg.STRICT_CMP) else ''
    return rel, 'EQUAL', (gdet + ' ' if gdet else '') + ('strict=' + strict if strict else '')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--jobs', type=int, default=3)
    ap.add_argument('--filter', default=None)
    ap.add_argument('--workdir', default='/tmp/slang-uhdm-probe')
    ap.add_argument('--timeout', type=int, default=120)
    a = ap.parse_args()
    for env, tool in (('SLANG_UHDM', vg.SLANG_UHDM), ('UHDM_CMP', vg.UHDM_CMP)):
        if not os.path.exists(tool):
            sys.exit(f'missing tool: {tool} (set ${env}; see tests/README.md)')
    todo = cases(a.filter)
    os.makedirs(a.workdir, exist_ok=True)
    counts, bad, built, strict = {}, [], 0, {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=a.jobs) as pool:
        for rel, st, det in pool.map(lambda r: check(r, a.workdir, a.timeout), todo):
            counts[st] = counts.get(st, 0) + 1
            built += det.startswith('built')
            if 'strict=' in det:
                s = det.split('strict=')[1].split('(')[0]
                strict[s] = strict.get(s, 0) + 1
            if st != 'EQUAL':
                bad.append((rel, st, det))
    for rel, st, det in bad:
        print(f'{st} {rel} {det}')
    print('probe cases: ' + ' '.join(f'{k}={v}' for k, v in sorted(counts.items())) +
          f' (of {len(todo)}); goldens built now={built}, from cache={len(todo) - built}')
    if strict:
        print('probe strict (measurement): ' + ' '.join(f'{k}={v}' for k, v in sorted(strict.items(), key=lambda kv: -kv[1])))
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
