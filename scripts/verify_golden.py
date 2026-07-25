#!/usr/bin/env python3
"""Compare slang-uhdm's UHDM against Surelog's, over either corpus, two ways.

Claiming "equal to golden" needs both halves of the picture, so every test can
be run in two modes:

  default   -- both tools get the source files and nothing else.  Isolates the
               emitter from all flag handling: if this fails, the model itself
               differs.
  testflags -- Surelog gets the test's own command line VERBATIM; slang-uhdm
               gets the same line with the UHDM-irrelevant parts removed
               (caching, threading, logging, preprocessor dumps, output paths).
               Nothing UHDM-relevant is ever dropped silently: an unimplemented
               UHDM-relevant flag classes the test UNTRANSLATABLE and names the
               flag.

slang-uhdm deliberately does NOT mirror Surelog's whole CLI -- it is a UHDM
emitter, not a Surelog clone.  General compiler options are slang's business
and Surelog-only plumbing is nobody's.  The asymmetry lives here instead.

Corpora:
  surelog     ~/git-repos/Surelog/{tests,third_party/tests} -- one `<Name>.sl`
              command line per test (794 of them).
  uhdm2rtlil  ~/git-repos/uhdm2rtlil/test -- `dut.sv`/`dut.v` per dir, or a
              `project.f` filelist naming several sources plus directives.

Statuses: CMP_EQUAL, CMP_NOTEQUAL, SLANG_REJECT, SURELOG_FAIL, NO_UHDM,
UNTRANSLATABLE, NO_DATABASE, TIMEOUT.
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
UHDM2RTLIL_TESTS = os.path.join(HOME, 'git-repos', 'uhdm2rtlil', 'test')
SURELOG = os.path.join(SURELOG_ROOT, 'build', 'bin', 'surelog')
SLANG_UHDM = os.environ.get('SLANG_UHDM',
                            os.path.join(HOME, 'git-repos', 'slang-uhdm', 'build', 'slang-uhdm'))
UHDM_CMP = os.path.join(HOME, 'git-repos', 'UHDM', 'build', 'bin', 'uhdm-cmp')
UVM_DIR = os.path.join(SURELOG_ROOT, 'third_party', 'UVM')

SRC_EXTS = ('.v', '.sv', '.vh', '.svh', '.pkg', '.vlt')

# ---------------------------------------------------------------------------
# Surelog flag classification.
#
# Only the UHDM-relevant set matters to slang-uhdm.  Everything else is dropped
# here, on the harness side, so Surelog still runs with its full command line.

# Number of arguments each flag consumes, for splitting sources from options.
FLAG_ARITY = {
    '-d': 1, '-o': 1, '-l': 1, '-cache': 1, '-split': 1, '-mt': 1, '-mp': 1,
    '--threads': 1, '-odir': 1, '--Mdir': 1, '-writeppfile': 1, '-builtin': 1,
    '-y': 1, '-v': 1, '-map': 1, '-L': 1, '-top': 1, '--top-module': 1,
    '-bb_mod': 1, '-bb_inst': 1, '-cfg': 1, '-cfgfile': 1, '-batch': 1,
    '-f': 1, '-F': 1, '-wd': 1, '-cd': 1, '-exe': 1, '-pythonlistenerfile': 1,
    '-remap': 2, '-cmd_ign': 2, '-cmd_ren': 2, '-cmd_mrg': 2,
}

# No effect on the database: caching, threading, logging, preprocessor output,
# output location, Python hooks, GC, EDA-compat shims.  `-nopython` and
# `-gc`/`-nogc` were each measured at 0 dump-line change.
IRRELEVANT_NOARG = {
    '-parse', '-nocache', '-noprecompiledcache', '-nowritecache', '-nohash',
    '-createcache', '-writepp', '-lineoffsetascomments', '-outputlineinfo',
    '-pploc', '-ppextra_loc', '-filterdirectives', '-filtercomments',
    '-filterprotected', '-verbose', '-nostdout', '-profile', '-replay',
    '-noinfo', '-nonote', '-nowarning', '-lowmem', '-batch', '-split',
    '-nopython', '-gc', '-nogc', '-init', '-pythonlistener',
    '-sv', '-sverilog',  # slang parses SystemVerilog unconditionally
    # Foreign simulator flags (VCS, Verilator) that appear in .sl files.  Surelog
    # accepts and ignores them: each was measured at 0 dump-line change.
    '-ast', '-PP', '-full64', '-notice', '-line', '-Os', '-quiet', '+v2k',
    '--assert', '--trace', '-output-split',
}
IRRELEVANT_PREFIX = ('+vcs+', '+warn=', '+lint=', '+OVM_TESTNAME=', '-Wno-')
IRRELEVANT_ONEARG = {'-d', '-o', '-l', '-cache', '-odir', '--Mdir', '-mt', '-mp',
                     '--threads', '-writeppfile', '-pythonlistenerfile', '-builtin',
                     '-exe', '-wd', '-cd', '-CFLAGS'}
IRRELEVANT_TWOARG = {'-remap', '-cmd_ign', '-cmd_ren', '-cmd_mrg'}

# UHDM-relevant, translatable.
ONEARG_MAP = {'-y': '-y', '-v': '-v', '-map': '--libmap', '-L': '-L',
              '-top': '--top', '--top-module': '--top', '-f': '-f', '-F': '-F'}

# UHDM-relevant but not implemented in slang-uhdm: these BLOCK a comparison.
# -cfg/-cfgfile select Verilog config blocks; -bb_* blackbox parts of the
# design; --disable-feature changes parameter/let elaboration.
BLOCKING_NOARG = {'-diffcompunit', '-sepcomp', '-link',
                  '-pythonevalscript', '-pythonevalscriptperfile'}
BLOCKING_ONEARG = {'-bb_mod', '-bb_inst', '-cfg', '-cfgfile'}

# Surelog emits no database at all: nothing to compare.
NO_DATABASE = {'-noparse', '-nocomp', '-noelab', '-nouhdm', '-parseonly'}


def split_sources(parts):
    """Split a Surelog argv into (sources, options), honouring flag arity."""
    sources, options = [], []
    i = 0
    while i < len(parts):
        p = parts[i]
        if p.startswith(('-', '+')):
            arity = FLAG_ARITY.get(p, 0)
            # `-sv <file>` forces one file to SystemVerilog; the file is still a
            # source, and slang needs no flag for it.
            if p in ('-sv', '-sverilog'):
                arity = 0
            options.append(p)
            options.extend(parts[i + 1:i + 1 + arity])
            i += 1 + arity
            continue
        sources.append(p)
        i += 1
    return sources, options


# Args that tell a tool WHERE the sources are, as opposed to shaping the model
# built from them: include paths, macro defines, library search, command files.
# `default` mode keeps these -- without them many tests cannot compile at all,
# and a comparison of two failed compiles measures nothing.  Model-shaping flags
# (-elabuhdm, -fileunit, -synth, -top, -P, -timescale, -cfg, -bb_*) are what
# `default` mode deliberately excludes.
LOCATION_ONEARG = {'-y', '-v', '-map', '-L', '-f', '-F', '-I', '--libext', '-Y'}
LOCATION_PREFIX = ('-I', '-D', '+incdir+', '+define+', '+libext+', '-U')


def location_args(parts):
    """Extract the point-at-and-parse-the-sources args.

    Returns (shared, surelog_only).  `-sv`/`-sverilog` is Surelog-only: it is a
    parse-mode switch, not a model-shaping one, and Surelog genuinely needs it
    (a `.v` file holding class syntax is 10 syntax errors and no database
    without it) whereas slang parses SystemVerilog unconditionally.
    """
    shared, surelog_only = [], []
    i = 0
    while i < len(parts):
        p = parts[i]
        if p in LOCATION_ONEARG:
            shared += [p, parts[i + 1]] if i + 1 < len(parts) else [p]
            i += 2
            continue
        if p in ('-sv', '-sverilog'):
            if p not in surelog_only:
                surelog_only.append(p)
        elif p.startswith(LOCATION_PREFIX) and p not in ('-D', '-I'):
            shared.append(p)
        i += 1
    return shared, surelog_only


def translate(parts):
    """Surelog argv -> (slang argv, blocking flags, nodb flags, nobuiltin).

    `blocking` non-empty means the comparison must not run: the two tools would
    be solving different problems.
    """
    args, blocking, nodb = [], [], []
    fileunit = False
    nobuiltin = False   # slang-uhdm, like Surelog, emits builtins by default
    i = 0
    while i < len(parts):
        p = parts[i]
        if p in IRRELEVANT_TWOARG:
            i += 3
            continue
        if p in IRRELEVANT_ONEARG:
            i += 2
            continue
        if p in IRRELEVANT_NOARG:
            i += 1
            continue
        if p in NO_DATABASE:
            nodb.append(p)
        elif p in BLOCKING_NOARG:
            blocking.append(p)
        elif p in BLOCKING_ONEARG:
            blocking.append(p)
            i += 2
            continue
        elif p == '-nobuiltin':
            nobuiltin = True
        elif p == '-elabuhdm':
            args.append('--elabuhdm')
        elif p == '-fileunit':
            fileunit = True
        elif p == '-synth':
            args.append('--synth')
        elif p == '-formal':
            args.append('--formal')
        elif p in ONEARG_MAP:
            args += [ONEARG_MAP[p], parts[i + 1]]
            i += 2
            continue
        elif p.startswith('-timescale='):
            args += ['--timescale', p.split('=', 1)[1]]
        elif p.startswith('--disable-feature=') or p.startswith('--enable-feature='):
            blocking.append(p)
        elif p.startswith(('-D', '-I', '+incdir+', '+define+', '+libext+')):
            args.append(p)  # slang parses the plus-delimited Verilog forms itself
        elif p.startswith('-P') and '=' in p:
            args.append('-G' + p[2:])          # top-level parameter override
        elif p.startswith('-pvalue+') and '=' in p:
            args.append('-G' + p[len('-pvalue+'):])
        elif p.startswith('+') or p.startswith('-'):
            if p in ('+liborder', '+librescan', '+libverbose', '+nolibcell'):
                pass                            # Surelog documents these as ignored
            elif p.startswith(IRRELEVANT_PREFIX):
                pass                            # measured DB-neutral
            else:
                blocking.append(p)              # unknown: never guess
        else:
            args.append(p)                      # a source file
        i += 1

    # Surelog compiles all files as ONE unit unless -fileunit; slang's default
    # is per-file, so the flag sits on the opposite side of the same choice.
    if not fileunit:
        args.append('--single-unit')
    return args, blocking, nodb, nobuiltin


# ---------------------------------------------------------------- discovery

def _find_files(dirpath, pattern):
    return sorted(os.path.relpath(m, dirpath)
                  for m in glob.glob(os.path.join(dirpath, pattern)))


def preprocess_sl(sl_path, dirpath):
    """Fold a `.sl` file into argv, mirroring Surelog's scripts/regression.py."""
    with open(sl_path, 'rt') as strm:
        cmdline = strm.read().strip()
    cmdline = cmdline.replace('\r', '').replace('\\', '').replace('\n', ' ').strip()
    cmdline = re.sub(r'[.\\/]+[\\/]UVM', UVM_DIR, cmdline)
    for ext in ('*/*.v', '*/*.sv'):
        if ext in cmdline:
            cmdline = cmdline.replace(ext, ' '.join(_find_files(dirpath, ext)))
    cmdline = re.sub(r'-mt\s+(max|\d+)', '', cmdline)
    cmdline = re.sub(r'-mp\s+(max|\d+)', '', cmdline)

    out = []
    for part in (p for p in cmdline.split(' ') if p):
        if ('*' in part or '?' in part) and part.endswith(('.v', '.sv', '.pkg')):
            out.extend(_find_files(dirpath, part))
        else:
            out.append(part)
    return out


def discover_surelog(pattern):
    """One test per `*.sl`, exactly as regression.py scans."""
    tests = {}
    for root in (os.path.join(SURELOG_ROOT, 'tests'),
                 os.path.join(SURELOG_ROOT, 'third_party', 'tests')):
        for dirpath, _dirs, files in os.walk(root):
            for fn in files:
                if not fn.endswith('.sl'):
                    continue
                name = fn[:-3]
                if pattern and not re.search(pattern, name):
                    continue
                sl = os.path.join(dirpath, fn)
                tests[name] = (dirpath, preprocess_sl(sl, dirpath))
    return dict(sorted(tests.items(), key=lambda kv: kv[0].lower()))


def parse_project_f(path):
    """uhdm2rtlil filelist: `# key: value` directives plus source lines."""
    srcs, directives = [], {}
    with open(path, 'rt') as strm:
        for raw in strm:
            line = raw.rstrip('\r\n').strip()
            if not line:
                continue
            m = re.match(r'^#\s*([a-z]+)\s*:\s*(.*)$', line)
            if m:
                directives[m.group(1)] = m.group(2).strip()
                continue
            if line.startswith('#'):
                continue
            srcs.append(line)
    return srcs, directives


def discover_uhdm2rtlil(pattern):
    """One test per dir; `project.f` overrides the dut.sv/dut.v default."""
    tests = {}
    for name in sorted(os.listdir(UHDM2RTLIL_TESTS)):
        dirpath = os.path.join(UHDM2RTLIL_TESTS, name)
        if not os.path.isdir(dirpath):
            continue
        if pattern and not re.search(pattern, name):
            continue
        srcs, directives = [], {}
        pf = os.path.join(dirpath, 'project.f')
        if os.path.isfile(pf):
            srcs, directives = parse_project_f(pf)
        if not srcs:
            for cand in ('dut.sv', 'dut.v'):
                if os.path.isfile(os.path.join(dirpath, cand)):
                    srcs = [cand]
                    break
        if not srcs:
            continue
        # The reference runner (test/test_uhdm_workflow.sh + project_files.sh)
        # passes `-parse -nobuiltin -nocache`, the project's own surelog
        # directive, and `-sv` whenever ANY source is .sv.
        opts = ['-parse', '-nobuiltin', '-nocache']
        opts += shlex.split(directives.get('surelog', ''))
        lang = directives.get('lang')
        if lang:
            opts += shlex.split(lang)
        elif any(s.endswith('.sv') for s in srcs):
            opts.append('-sv')
        if 'top' in directives and '-top' not in opts:
            opts += ['-top', directives['top']]
        tests[name] = (dirpath, opts + srcs)
    return tests


# ---------------------------------------------------------------- execution

def find_uhdm(workdir):
    hits = []
    for sub in ('slpp_all', 'slpp_unit'):
        hits += sorted(glob.glob(os.path.join(workdir, sub, '*.uhdm')))
    return hits


def compare(name, mode, dirpath, sl_args, su_args, workroot, timeout):
    work = os.path.join(workroot, mode, name)
    os.makedirs(work, exist_ok=True)

    sl_argv = [SURELOG] + sl_args + ['-mt', '0', '-mp', '0', '-o', work]
    with open(os.path.join(work, 'cmds.txt'), 'wt') as f:
        f.write('surelog: ' + shlex.join(sl_argv) + '\n')
    try:
        sl = subprocess.run(sl_argv, cwd=dirpath, capture_output=True, text=True,
                            timeout=timeout)
    except subprocess.TimeoutExpired:
        return (name, mode, 'TIMEOUT', 'surelog timeout', '')

    uhdms = find_uhdm(work)
    if not uhdms:
        tail = (sl.stdout or sl.stderr or '').strip().splitlines()
        return (name, mode, 'SURELOG_FAIL' if sl.returncode else 'NO_UHDM',
                tail[-1][:140] if tail else f'rc={sl.returncode}', '')
    if len(uhdms) > 1:
        return (name, mode, 'NO_UHDM', f'{len(uhdms)} databases (fileunit)', '')

    slang_out = os.path.join(work, 'slang.uhdm')
    su_argv = [SLANG_UHDM] + su_args + ['-o', slang_out]
    with open(os.path.join(work, 'cmds.txt'), 'at') as f:
        f.write('slang:   ' + shlex.join(su_argv) + '\n')
    try:
        su = subprocess.run(su_argv, cwd=dirpath, capture_output=True, text=True,
                            timeout=timeout)
    except subprocess.TimeoutExpired:
        return (name, mode, 'TIMEOUT', 'slang timeout', '')
    if not os.path.exists(slang_out):
        tail = (su.stderr or su.stdout or '').strip().splitlines()
        msg = next((l for l in tail if 'error' in l.lower()), tail[-1] if tail else '')
        return (name, mode, 'SLANG_REJECT', msg[:140] or f'rc={su.returncode}', '')

    try:
        cp = subprocess.run([UHDM_CMP, uhdms[0], slang_out], capture_output=True,
                            text=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        return (name, mode, 'TIMEOUT', 'uhdm-cmp timeout', '')
    if cp.returncode == 0:
        return (name, mode, 'CMP_EQUAL', '', '')
    tail = (cp.stdout or cp.stderr or '').strip().splitlines()
    return (name, mode, 'CMP_NOTEQUAL', tail[0][:140] if tail else '', '')


def run_one(name, dirpath, parts, modes, workroot, timeout):
    sources, _options = split_sources(parts)
    results = []

    if 'default' in modes:
        # Both tools get the sources plus only the args saying where to find
        # them; no model-shaping flag on either side.  `-parse` is not a test
        # option, it is what makes Surelog emit a database at all.  Surelog's
        # default is one compilation unit, so slang needs --single-unit to match
        # that default, and Surelog's default also parses its builtin classes.
        loc, sl_only = location_args(parts)
        su = loc + list(sources) + ['--single-unit']
        results.append(compare(name, 'default', dirpath,
                               ['-parse'] + loc + sl_only + sources, su,
                               workroot, timeout))

    if 'testflags' in modes:
        su_args, blocking, nodb, nobuiltin = translate(parts)
        if nodb:
            results.append((name, 'testflags', 'NO_DATABASE',
                            'test suppresses UHDM output', ' '.join(nodb)))
        elif blocking:
            results.append((name, 'testflags', 'UNTRANSLATABLE',
                            'UHDM-relevant flag not implemented in slang-uhdm',
                            ' '.join(blocking)))
        else:
            if nobuiltin:
                su_args.append('--nobuiltin')
            results.append(compare(name, 'testflags', dirpath, parts, su_args,
                                   workroot, timeout))
    return results


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--corpus', choices=['surelog', 'uhdm2rtlil'], required=True)
    ap.add_argument('--mode', choices=['default', 'testflags', 'both'], default='both')
    ap.add_argument('--out', required=True)
    ap.add_argument('--workdir', default='/tmp/verify_golden')
    ap.add_argument('--jobs', type=int, default=4)
    ap.add_argument('--timeout', type=int, default=180)
    ap.add_argument('--filter', default=None)
    args = ap.parse_args()

    for tool in (SURELOG, SLANG_UHDM, UHDM_CMP):
        if not os.path.exists(tool):
            sys.exit(f'missing tool: {tool}')

    modes = ['default', 'testflags'] if args.mode == 'both' else [args.mode]
    tests = (discover_surelog(args.filter) if args.corpus == 'surelog'
             else discover_uhdm2rtlil(args.filter))
    print(f'{len(tests)} tests in {args.corpus}; modes={",".join(modes)}', flush=True)
    os.makedirs(args.workdir, exist_ok=True)

    rows = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        futures = {pool.submit(run_one, n, d, p, modes, args.workdir,
                               args.timeout): n
                   for n, (d, p) in tests.items()}
        for done, fut in enumerate(concurrent.futures.as_completed(futures), 1):
            try:
                rows.extend(fut.result())
            except Exception as exc:
                rows.append((futures[fut], 'harness', 'SURELOG_FAIL',
                             f'{exc}'[:140], ''))
            if done % 25 == 0:
                print(f'  {done}/{len(tests)}', flush=True)

    rows.sort(key=lambda r: (r[0].lower(), r[1]))
    with open(args.out, 'wt') as f:
        f.write('name,mode,status,detail,blocked_by\n')
        for name, mode, status, detail, blocked in rows:
            detail = detail.replace(',', ';').replace('\n', ' ')
            f.write(f'{name},{mode},{status},{detail},{blocked}\n')

    for mode in modes:
        counts = {}
        for _n, m, status, _d, _b in rows:
            if m == mode:
                counts[status] = counts.get(status, 0) + 1
        total = sum(counts.values())
        print(f'\n[{mode}] {total} tests')
        for k, v in sorted(counts.items(), key=lambda kv: -kv[1]):
            print(f'  {k}: {v}')


if __name__ == '__main__':
    main()
