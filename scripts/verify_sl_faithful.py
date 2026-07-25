#!/usr/bin/env python3
"""Cross-tool UHDM comparison that runs each test its OWN way.

Surelog's regression suite is a self-regression: every test dir carries a
`<Name>.sl` command line and a golden `<Name>.log`, and scripts/regression.py
checks Surelog's log against that golden.  Nothing in it compares UHDM
databases across tools, so a cross-tool check has to be built -- but it must
use each test's real command line, not a uniform happy path.

This script therefore:
  * discovers tests exactly as regression.py does (`*.sl` under the test roots),
  * preprocesses the command line the same way (backslash/newline folding,
    glob expansion, -mt/-mp stripping, UVM path rewrite),
  * runs Surelog with those args verbatim,
  * translates the SAME args for slang-uhdm, and refuses to guess: any flag
    without a faithful slang equivalent is reported in the `untranslated`
    column and the test is classed UNTRANSLATABLE rather than silently run
    with the flag dropped,
  * compares the two databases with the standard uhdm-cmp.

Statuses: CMP_EQUAL, CMP_NOTEQUAL, SLANG_REJECT, SURELOG_FAIL, NO_UHDM,
UNTRANSLATABLE, TIMEOUT.
"""

import argparse
import concurrent.futures
import glob
import os
import re
import shlex
import subprocess
import sys

HOME = os.path.expanduser('~')
SURELOG_ROOT = os.path.join(HOME, 'git-repos', 'Surelog')
DEFAULT_ROOTS = [os.path.join(SURELOG_ROOT, 'tests'),
                 os.path.join(SURELOG_ROOT, 'third_party', 'tests')]
SURELOG = os.path.join(SURELOG_ROOT, 'build', 'bin', 'surelog')
SLANG_UHDM = os.environ.get('SLANG_UHDM',
                            os.path.join(HOME, 'git-repos', 'slang-uhdm', 'build', 'slang-uhdm'))
UHDM_CMP = os.path.join(HOME, 'git-repos', 'UHDM', 'build', 'bin', 'uhdm-cmp')
UVM_DIR = os.path.join(SURELOG_ROOT, 'third_party', 'UVM')


# ---------------------------------------------------------------- discovery

def discover(roots, pattern):
    """Same walk as regression.py::_scan -- every `*.sl` is one test."""
    tests = {}
    for root in roots:
        for dirpath, _dirnames, filenames in os.walk(root):
            for filename in filenames:
                if filename.endswith('.sl'):
                    name = filename[:-3]
                    if pattern and not re.search(pattern, name):
                        continue
                    tests[name] = os.path.join(dirpath, filename)
    return dict(sorted(tests.items(), key=lambda kv: kv[0].lower()))


def _find_files(dirpath, pattern):
    """regression.py::_find_files -- expand a glob relative to the test dir."""
    matches = sorted(glob.glob(os.path.join(dirpath, pattern)))
    return [os.path.relpath(m, dirpath) for m in matches]


def preprocess(sl_path, dirpath):
    """Fold a `.sl` file into an argv list, mirroring regression.py."""
    with open(sl_path, 'rt') as strm:
        cmdline = strm.read().strip()

    cmdline = cmdline.replace('\r', '').replace('\\', '').replace('\n', ' ').strip()
    # regression.py rewrites relative UVM references to the real UVM checkout.
    cmdline = re.sub(r'[.\\/]+[\\/]UVM', UVM_DIR, cmdline)

    for ext in ('*/*.v', '*/*.sv'):
        if ext in cmdline:
            cmdline = cmdline.replace(ext, ' '.join(_find_files(dirpath, ext)))
    # Threading is forced off below, so drop any test-specified level.
    cmdline = re.sub(r'-mt\s+(max|\d+)', '', cmdline)
    cmdline = re.sub(r'-mp\s+(max|\d+)', '', cmdline)

    parts = [p for p in cmdline.split(' ') if p]
    out = []
    for part in parts:
        if ('*' in part or '?' in part) and part.endswith(('.v', '.sv', '.pkg')):
            out.extend(_find_files(dirpath, part))
        else:
            out.append(part)
    return out


# ---------------------------------------------------------------- translation

# Surelog flags with no effect on the UHDM database: debug dumps, caching,
# preprocessor output, logging, threading, output location.
DROP_NOARG = {
    '-parse', '-nocache', '-nocache-parse', '-createcache', '-writepp', '-verbose',
    '-batch', '-split', '-lowmem', '-ast', '-nobuiltin-parse', '-filterprotected',
    '-pythonlistener', '-pythonevalscript', '-pythonevalscriptperfile',
    '-sv', '-sverilog',  # slang parses SystemVerilog for .v and .sv alike
    # Verified to leave the UHDM database byte-identical.
    '-nopython', '-noprecompiledcache', '-nowritecache',
}
DROP_ONEARG = {'-d', '-o', '-pythonlistenerfile'}

# Flags whose semantics we cannot reproduce faithfully.  Never dropped
# silently -- they mark the test UNTRANSLATABLE.  `-synth` is here because it
# measurably perturbs the database (81 dump lines on ParamArraySelect), and
# `-f`/`-F` because Surelog command files hold Surelog-syntax flags that would
# need recursive translation before slang could consume them.
UNSUPPORTED_NOARG = {'-bb_mod', '-bb_inst', '-cfg', '-cfgfile', '-diffcompunit',
                     '-synth', '-formal', '-f', '-F'}

# Flags that suppress the database entirely: there is nothing to compare.
NO_DATABASE = {'-nouhdm', '-noelab', '-nocomp'}


def translate(parts, dirpath):
    """Surelog argv -> (slang argv, untranslated flags, needs_builtins).

    Returns untranslated as a list; a non-empty list means we must NOT run the
    comparison, because the two tools would be given different problems.
    """
    args = []
    untranslated = []
    fileunit = False
    needs_builtins = True  # Surelog parses SV builtin classes unless told not to
    i = 0
    while i < len(parts):
        p = parts[i]
        if p in DROP_ONEARG:
            i += 2
            continue
        if p in DROP_NOARG:
            i += 1
            continue
        if p == '-nobuiltin':
            needs_builtins = False
        elif p == '-elabuhdm':
            args.append('--elabuhdm')
        elif p == '-fileunit':
            fileunit = True
        elif p in ('-top', '--top-module'):
            args += ['--top', parts[i + 1]]
            i += 2
            continue
        elif p in ('-y', '-v', '-map'):
            args += [{'-y': '-y', '-v': '-v', '-map': '--libmap'}[p], parts[i + 1]]
            i += 2
            continue
        elif p in NO_DATABASE:
            untranslated.append(p)
        elif p.startswith('-Wno-'):
            pass  # lint suppression only
        elif p.startswith('-timescale='):
            args += ['--timescale', p.split('=', 1)[1]]
        elif p.startswith('-D'):
            args.append(p)
        elif p.startswith('-I'):
            args.append(p)
        elif p.startswith('-P') and '=' in p:
            # Surelog -P<param>=<value> is a top-level parameter override.
            args.append('-G' + p[2:])
        elif p in UNSUPPORTED_NOARG or p.startswith('--disable-feature='):
            untranslated.append(p)
        elif p.startswith('-'):
            untranslated.append(p)
        else:
            args.append(p)  # a source file
        i += 1

    # Surelog compiles all files as ONE compilation unit unless -fileunit is
    # given; slang's default is the opposite, so the mapping inverts.
    if not fileunit:
        args.append('--single-unit')
    return args, untranslated, needs_builtins


# ---------------------------------------------------------------- execution

def find_uhdm(dirpath):
    hits = []
    for sub in ('slpp_all', 'slpp_unit'):
        hits += sorted(glob.glob(os.path.join(dirpath, sub, '*.uhdm')))
    return hits


def run_one(name, sl_path, outroot, timeout):
    dirpath = os.path.dirname(sl_path)
    work = os.path.join(outroot, name)
    os.makedirs(work, exist_ok=True)

    try:
        parts = preprocess(sl_path, dirpath)
    except OSError as exc:
        return (name, 'SURELOG_FAIL', f'sl unreadable: {exc}', '')

    slang_args, untranslated, needs_builtins = translate(parts, dirpath)
    if untranslated:
        return (name, 'UNTRANSLATABLE', 'no faithful slang equivalent',
                ' '.join(untranslated))
    if needs_builtins:
        # Without -nobuiltin Surelog parses its builtin SV classes into the
        # database; we have no equivalent, so the comparison would be unfair.
        return (name, 'UNTRANSLATABLE', 'test omits -nobuiltin (Surelog emits builtin classes)',
                'builtins')

    # Surelog runs in the test dir, writing under our per-test work dir.
    sl_argv = [SURELOG] + parts + ['-mt', '0', '-mp', '0', '-o', work]
    try:
        sl = subprocess.run(sl_argv, cwd=dirpath, capture_output=True, text=True,
                            timeout=timeout)
    except subprocess.TimeoutExpired:
        return (name, 'TIMEOUT', 'surelog timeout', '')
    with open(os.path.join(work, 'surelog.cmd'), 'wt') as f:
        f.write(shlex.join(sl_argv) + '\n')

    uhdms = find_uhdm(work)
    if not uhdms:
        detail = (sl.stdout or sl.stderr or '').strip().splitlines()
        return (name, 'SURELOG_FAIL' if sl.returncode else 'NO_UHDM',
                detail[-1][:140] if detail else f'rc={sl.returncode}', '')
    if len(uhdms) > 1:
        return (name, 'NO_UHDM', f'{len(uhdms)} databases (fileunit)', '')

    slang_out = os.path.join(work, 'slang.uhdm')
    su_argv = [SLANG_UHDM] + slang_args + ['-o', slang_out]
    with open(os.path.join(work, 'slang.cmd'), 'wt') as f:
        f.write(shlex.join(su_argv) + '\n')
    try:
        su = subprocess.run(su_argv, cwd=dirpath, capture_output=True, text=True,
                            timeout=timeout)
    except subprocess.TimeoutExpired:
        return (name, 'TIMEOUT', 'slang timeout', '')
    if not os.path.exists(slang_out):
        detail = (su.stderr or su.stdout or '').strip().splitlines()
        return (name, 'SLANG_REJECT', detail[-1][:140] if detail else f'rc={su.returncode}', '')

    cmp_proc = subprocess.run([UHDM_CMP, uhdms[0], slang_out],
                              capture_output=True, text=True, timeout=timeout)
    if cmp_proc.returncode == 0:
        return (name, 'CMP_EQUAL', '', '')
    detail = (cmp_proc.stdout or cmp_proc.stderr or '').strip().splitlines()
    return (name, 'CMP_NOTEQUAL', detail[0][:140] if detail else '', '')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--roots', nargs='*', default=DEFAULT_ROOTS)
    ap.add_argument('--out', required=True, help='CSV output path')
    ap.add_argument('--workdir', default='/tmp/sl_faithful')
    ap.add_argument('--jobs', type=int, default=3)
    ap.add_argument('--timeout', type=int, default=180)
    ap.add_argument('--filter', default=None, help='regex on test name')
    args = ap.parse_args()

    for tool in (SURELOG, SLANG_UHDM, UHDM_CMP):
        if not os.path.exists(tool):
            sys.exit(f'missing tool: {tool}')

    tests = discover(args.roots, args.filter)
    print(f'{len(tests)} tests discovered', flush=True)
    os.makedirs(args.workdir, exist_ok=True)

    rows = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        futures = {pool.submit(run_one, n, p, args.workdir, args.timeout): n
                   for n, p in tests.items()}
        for done, fut in enumerate(concurrent.futures.as_completed(futures), 1):
            try:
                rows.append(fut.result())
            except Exception as exc:  # keep the sweep going
                rows.append((futures[fut], 'SURELOG_FAIL', f'harness: {exc}'[:140], ''))
            if done % 25 == 0:
                print(f'  {done}/{len(tests)}', flush=True)

    rows.sort(key=lambda r: r[0].lower())
    with open(args.out, 'wt') as f:
        f.write('name,status,detail,untranslated\n')
        for name, status, detail, untr in rows:
            detail = detail.replace(',', ';').replace('\n', ' ')
            f.write(f'{name},{status},{detail},{untr}\n')

    counts = {}
    for _n, status, _d, _u in rows:
        counts[status] = counts.get(status, 0) + 1
    print('\n'.join(f'{k}: {v}' for k, v in sorted(counts.items(), key=lambda kv: -kv[1])))


if __name__ == '__main__':
    main()
