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
  folded    -- diagnostic overlay for the -elabuhdm tests only: the test's own
               flags minus -elabuhdm on BOTH sides, comparing the folded models
               those tests never normally show.  Elab output is derived from
               the folded tree by shared UHDM library code, so a test that is
               folded-not-equal should be fixed folded-first; one that is
               folded-equal but testflags-not-equal is an elab-frontier bug.
               Tests without -elabuhdm produce no folded row (testflags already
               compares their folded model).

slang-uhdm deliberately does NOT mirror Surelog's whole CLI -- it is a UHDM
emitter, not a Surelog clone.  General compiler options are slang's business
and Surelog-only plumbing is nobody's.  The asymmetry lives here instead.

Corpora:
  surelog     third_party/Surelog/{tests,third_party/tests} -- one `<Name>.sl`
              command line per test (794 of them).
  uhdm2rtlil  third_party/uhdm2rtlil/test -- `dut.sv`/`dut.v` per dir, or a
              `project.f` filelist naming several sources plus directives.

Statuses: CMP_EQUAL, STRICT_NOTEQUAL, CMP_NOTEQUAL, SLANG_REJECT,
SURELOG_FAIL, NO_UHDM, UNTRANSLATABLE, NO_DATABASE, TIMEOUT, DEFERRED.
Since the strict flip (2026-09-24) a row is CMP_EQUAL only when uhdm-cmp reads
the pair equal AND uhdm-strictcmp reads it STRICT_EQUAL; a pair uhdm-cmp reads
equal that the strict comparator does not is STRICT_NOTEQUAL, with the strict
verdict in the detail column (and, as on every judge-equal row, in `strict`).
"""

import argparse
import concurrent.futures
import glob
import os
import re
import shlex
import shutil
import subprocess
import sys

# ---------------------------------------------------------------- locations
#
# Everything the sweep needs is resolved relative to THIS repository so a
# fresh clone runs the same two corpora the same way:
#   third_party/Surelog     the pinned Surelog (producer binary, its test
#                           suite, third_party/tests and third_party/UVM)
#   third_party/uhdm2rtlil  the pinned uhdm2rtlil checkout (its test/ corpus)
# The producer tools come from the Surelog submodule's build tree
# (build/bin/surelog, build/third_party/UHDM/bin/uhdm-{cmp,dump}); every
# location can be overridden by the environment variable of the same name.
REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SURELOG_ROOT = os.environ.get('SURELOG_ROOT') or os.path.join(
    REPO_ROOT, 'third_party', 'Surelog')
UHDM2RTLIL_TESTS = os.environ.get('UHDM2RTLIL_TESTS') or os.path.join(
    REPO_ROOT, 'third_party', 'uhdm2rtlil', 'test')


def _tool(env, *candidates):
    """First existing candidate, else the first one (so the error names it)."""
    v = os.environ.get(env)
    if v:
        return v
    for c in candidates:
        if c and os.path.exists(c):
            return c
    return candidates[0]


SURELOG = _tool('SURELOG', os.path.join(SURELOG_ROOT, 'build', 'bin', 'surelog'),
                shutil.which('surelog'))
SLANG_UHDM = _tool('SLANG_UHDM', os.path.join(REPO_ROOT, 'build', 'slang-uhdm'))
# uhdm-cmp / uhdm-dump: the Surelog submodule's build tree first, then this
# tree's own in-tree build of the same UHDM commit, then PATH.
_UHDM_BINS = (os.path.join(SURELOG_ROOT, 'build', 'third_party', 'UHDM', 'bin'),
              os.path.join(REPO_ROOT, 'build', 'third_party', 'Surelog', 'third_party', 'UHDM', 'bin'))
UHDM_CMP = _tool('UHDM_CMP', *[os.path.join(d, 'uhdm-cmp') for d in _UHDM_BINS],
                 shutil.which('uhdm-cmp'))
UHDM_DUMP = _tool('UHDM_DUMP', *[os.path.join(d, 'uhdm-dump') for d in _UHDM_BINS],
                  shutil.which('uhdm-dump'))
# uhdm-strictcmp (tools/uhdm-strictcmp): uhdm-cmp's verdict first, then the
# judge-blind fields; fills the sweep's `strict` column on every row uhdm-cmp
# reads equal, and decides CMP_EQUAL against STRICT_NOTEQUAL. REQUIRED: a
# missing binary stops the sweep (the gate must not pass without its equality).
STRICT_CMP = _tool('STRICT_CMP', os.path.join(REPO_ROOT, 'build', 'uhdm-strictcmp'),
                   os.path.join(REPO_ROOT, 'build-intree', 'uhdm-strictcmp'),
                   shutil.which('uhdm-strictcmp'))

# ---------------------------------------------------------------- golden cache
#
# The golden side is IMMUTABLE: Surelog's database for a given (test dir,
# argv) never changes while the Surelog binary and test sources are pinned.
# Re-running Surelog on every sweep -- by every agent, every verifier, every
# gate -- regenerated byte-identical goldens thousands of times and dominated
# sweep wall-clock. Cache key: Surelog's version line + the test dir and argv
# spelled relative to the corpus roots (minus the run-local -o/-mt/-mp tail),
# so one cache serves every clone on a machine and can be copied between
# machines. The default location is ~/.cache/slang-uhdm-goldens; a fresh
# clone's first sweep fills it and every later sweep is served from it. Concurrent writers (worktree agents
# share this cache) stay safe via write-to-temp + atomic rename.
# GOLDEN_CACHE=0 disables; GOLDEN_CACHE=<dir> relocates.

import hashlib

_cache_env = os.environ.get('GOLDEN_CACHE', '')
CACHE_ENABLED = _cache_env != '0'
CACHE_ROOT = _cache_env if _cache_env not in ('', '0') else os.path.join(
    os.path.expanduser('~'), '.cache', 'slang-uhdm-goldens')


def _surelog_identity():
    """The producer's own version line ("VERSION: 1.87"), so the key is the
    same on every machine and every clone that runs the pinned Surelog."""
    try:
        out = subprocess.run([SURELOG, '--version'], capture_output=True,
                             text=True, timeout=60).stdout
    except (OSError, subprocess.SubprocessError):
        out = ''
    for line in out.splitlines():
        if line.startswith('VERSION'):
            return 'surelog ' + line.split(':', 1)[1].strip()
    st = os.stat(SURELOG)
    return '%s|%d|%d' % (SURELOG, st.st_mtime_ns, st.st_size)


def _surelog_revision():
    """The git commit the producer was built from, 12 hex digits, or 'norev'.

    Two Surelog builds of different commits can print the same version line,
    so the version line alone cannot name the goldens. The commit is read from
    the checkout that holds the binary (the pinned submodule by default)."""
    d = os.path.dirname(os.path.realpath(SURELOG))
    for _ in range(8):
        if os.path.exists(os.path.join(d, '.git')):
            try:
                out = subprocess.run(['git', '-C', d, 'rev-parse', 'HEAD'],
                                     capture_output=True, text=True, timeout=60).stdout.strip()
            except (OSError, subprocess.SubprocessError):
                out = ''
            if re.fullmatch(r'[0-9a-f]{40}', out):
                return out[:12]
            break
        up = os.path.dirname(d)
        if up == d:
            break
        d = up
    return 'norev'


_CACHE_BASE = None


def cache_base():
    """CACHE_ROOT/<surelog commit>: every golden lives under the commit of the
    producer that built it, so a moved Surelog pin never reads an old golden."""
    global _CACHE_BASE
    if _CACHE_BASE is None:
        _CACHE_BASE = os.path.join(CACHE_ROOT, _surelog_revision())
    return _CACHE_BASE


_IDENTITY = None


def _portable(s):
    """A path under a corpus root, spelled the same in every clone."""
    for tag, root in (('$SURELOG_ROOT', SURELOG_ROOT),
                      ('$UHDM2RTLIL_TESTS', UHDM2RTLIL_TESTS)):
        if s == root or s.startswith(root + os.sep):
            return tag + s[len(root):]
    return s


def _reaches_outside(sl_args):
    """True when any argument names a path outside the test's own directory
    (`..` or absolute). Surelog then spells `__FILE__` as an ABSOLUTE path,
    which lands in judged string constants (text and size), so the golden of
    such a test is specific to where the corpus is checked out."""
    return any(os.path.isabs(a) or '..' in a.split('/') or
               a.startswith(('-I..', '+incdir+..', '-y..', '-v..'))
               for a in sl_args)


def golden_cache_dir(dirpath, sl_args):
    global _IDENTITY
    if _IDENTITY is None:
        _IDENTITY = _surelog_identity()
    parts = [_IDENTITY, _portable(dirpath)] + [_portable(a) for a in sl_args]
    if _reaches_outside(sl_args):
        parts.append(os.path.abspath(dirpath))   # per-location golden
    key = hashlib.sha1('\0'.join(parts).encode()).hexdigest()[:20]
    return os.path.join(cache_base(), key)


# Failures are cached only when GOLDEN_CACHE_FAILURES=1 (a deliberate
# quiet-machine populate run). By default a failure is retried next sweep:
# genuine failures re-fail in seconds, while load-flake failures (OOM during
# Surelog's model write) would otherwise become PERMANENT — the cache is
# first-write-wins and a hit short-circuits the run, so a cached flake never
# gets another chance to succeed.
CACHE_FAILURES = os.environ.get('GOLDEN_CACHE_FAILURES', '') == '1'


def cache_store(cdir, uhdm_path, status_line):
    if uhdm_path is None and not CACHE_FAILURES:
        return
    # A killed writer must not publish or strand state: 0-byte/partial uhdm
    # files are never published (audit found one 0-byte live entry and ~200
    # orphaned .tmp staging dirs, ~20GB, from sweeps killed mid-dump).
    if uhdm_path is not None and os.path.getsize(uhdm_path) == 0:
        return
    tmp = None
    try:
        os.makedirs(cache_base(), exist_ok=True)
        tmp = cdir + '.tmp%d' % os.getpid()
        os.makedirs(tmp, exist_ok=True)
        if uhdm_path:
            shutil.copy2(uhdm_path, os.path.join(tmp, 'golden.uhdm'))
            # (golden.dumphash is no longer written: the strict column
            # replaced the dump comparison.)
        with open(os.path.join(tmp, 'status'), 'wt') as f:
            f.write(status_line)
        if not os.path.isdir(cdir):
            os.replace(tmp, cdir)
        else:
            shutil.rmtree(tmp)
    except (OSError, subprocess.TimeoutExpired):
        pass  # cache is best-effort
    finally:
        if tmp and os.path.isdir(tmp):
            shutil.rmtree(tmp, ignore_errors=True)


def cache_load(cdir):
    # -> (status_line, uhdm_path_or_None, dumphash_or_None), or None on miss
    try:
        with open(os.path.join(cdir, 'status'), 'rt') as f:
            status_line = f.read()
    except OSError:
        return None
    up = os.path.join(cdir, 'golden.uhdm')
    if os.path.isfile(up) and os.path.getsize(up) == 0:
        return None  # corrupt entry: treat as miss
    hp = os.path.join(cdir, 'golden.dumphash')
    dh = None
    if os.path.isfile(hp):
        with open(hp, 'rt') as f:
            dh = f.read().strip()
    return (status_line, up if os.path.isfile(up) else None, dh)


UVM_DIR = os.path.join(SURELOG_ROOT, 'third_party', 'UVM')

SRC_EXTS = ('.v', '.sv', '.vh', '.svh', '.pkg', '.vlt')

# Deferred to a late phase (user decision 2026-07-27): golden generation for
# these OOMs or times out on this machine, failures are uncacheable by design,
# and re-running them to the timeout dominated every sweep's wall-clock
# (~25 min of a ~35 min both-modes sweep). They emit status DEFERRED without
# running either tool. GOLDEN_DEFER=0 disables (for the late-phase revisit on
# capable hardware); GOLDEN_DEFER=<comma-list> overrides the set.
_defer_env = os.environ.get('GOLDEN_DEFER', '')
if _defer_env == '0':
    DEFERRED_TESTS = set()
elif _defer_env:
    DEFERRED_TESTS = set(_defer_env.split(','))
else:
    DEFERRED_TESTS = {'Earlgrey_nexysvideo', 'Earlgrey_Verilator_01_05_21',
                      'Rsd', 'Xgate', 'YosysSmallBoom'}

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

# Surelog SUBSTITUTES its own bundled UVM/OVM for any source file whose LEAF
# NAME is `uvm_pkg.sv` or `ovm_pkg.sv` (`Package/Precompiled.cpp`: the ctor
# registers exactly those two names, and `isFilePrecompiled` keys on the leaf
# alone).  A precompiled file is read from `<surelog-install>/pkg/work/*.slpp`
# with NO hash check, so the model Surelog emits describes the UVM that ships
# in the Surelog BUILD TREE (`bin/1800.2-2017-1.0/src`), not the UVM the test
# actually named on its command line.
#
# Measured on `Scoreboard` (which compiles `third_party/UVM/uvm-1.2`): the
# golden's `uvm_pkg` holds 41 parameters led by `UVM_VERSION_STRING` and
# `UVM_HDL_MAX_WIDTH` at `dpi/uvm_hdl.svh:54` -- both 1800.2-2017-1.0.  The
# uvm-1.2 sources on the command line have 45 parameters led by the
# `uvm_*_copyright` strings with `UVM_HDL_MAX_WIDTH` at `dpi/uvm_hdl.svh:47`.
# Re-run Surelog with `-noprecompiledcache` and its 45 parameters match
# slang-uhdm's 45 name-for-name and line-for-line.
#
# So the substitution is not a model difference we could ever emit -- it is the
# golden describing a different source text.  It also makes the golden depend
# on the Surelog build tree rather than on the test, which is the same class of
# environment leak as `-mt`/`-mp` (already pinned to 0 on the golden side).
# The guard is applied ONLY when a precompiled leaf name is actually present,
# so the golden-cache key -- and therefore every cached golden -- is unchanged
# for every other test in both corpora.
PRECOMPILED_LEAVES = ('uvm_pkg.sv', 'ovm_pkg.sv')


def precompiled_guard(parts):
    """['-noprecompiledcache'] when any argument names a file Surelog would
    serve from its bundled precompiled package cache, else []."""
    for p in parts:
        if os.path.basename(p) in PRECOMPILED_LEAVES:
            return ['-noprecompiledcache']
    return []


# No effect on the database: caching, threading, logging, preprocessor output,
# output location, Python hooks, GC, EDA-compat shims.  `-nopython` and
# `-gc`/`-nogc` were each measured at 0 dump-line change.
# NOTE `-noprecompiledcache` is listed here because dropping it from the SLANG
# side is right (slang has no such cache); it is emphatically NOT a no-op on the
# Surelog side -- see `precompiled_guard` above.
IRRELEVANT_NOARG = {
    '-parse', '-nocache', '-noprecompiledcache', '-nowritecache', '-nohash',
    '-createcache', '-writepp', '-lineoffsetascomments', '-outputlineinfo',
    '-pploc', '-ppextra_loc', '-filterdirectives', '-filtercomments',
    '-verbose', '-nostdout', '-profile', '-replay',
    '-noinfo', '-nonote', '-nowarning', '-lowmem', '-batch', '-split',
    '-nopython', '-gc', '-nogc', '-init', '-pythonlistener',
    '-sv',  # `-sv <file>`: slang parses SystemVerilog unconditionally
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

# UHDM-relevant, translatable.  slang-uhdm implements -bb_mod/-bb_inst with the
# same semantics and argument form as Surelog; only the dash count differs
# (slang's option registry requires `--` for multi-character names).
ONEARG_MAP = {'-y': '-y', '-v': '-v', '-map': '--libmap', '-L': '-L',
              '-top': '--top', '--top-module': '--top', '-f': '-f', '-F': '-F',
              '-bb_mod': '--bb_mod', '-bb_inst': '--bb_inst',
              '-cfg': '--cfg', '-cfgfile': '--cfgfile'}

# UHDM-relevant but not implemented in slang-uhdm: these BLOCK a comparison.
# (-bb_mod/-bb_inst and -cfg/-cfgfile were here until slang-uhdm implemented
# them; they are now in ONEARG_MAP.)
BLOCKING_NOARG = {'-diffcompunit', '-sepcomp', '-link',
                  '-pythonevalscript', '-pythonevalscriptperfile'}
BLOCKING_ONEARG = set()

# `--disable-feature=<a,b>` / `--enable-feature=<a,b>` take a COMMA LIST in one
# argv word, so they translate per FEATURE, not per flag: a feature slang-uhdm
# implements is passed through with Surelog's own spelling, anything else blocks
# the whole comparison.  A MIXED list blocks too -- dropping the unimplemented
# half would silently compare two different models (GOLDEN_EQUIVALENCE 2.3).
# Both of Surelog's features are implemented now, so nothing in this family
# blocks any more; the per-feature check stays because the table is the contract
# and a future Surelog feature must block on arrival, not be waved through.
IMPLEMENTED_FEATURES = {'parametersubstitution', 'letexprsubstitution'}

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

# Every LOCATION_ONEARG flag is spelled the same on both sides except `-map`,
# which slang spells `--libmap` (ONEARG_MAP already says so for testflags mode).
# Without this rename `default` mode handed slang a literal `-map`, which it
# rejects outright -- so the two -map tests read SLANG_REJECT with a harness
# error message rather than their real verdict.
LOCATION_RENAME = {'-map': '--libmap'}


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
        elif p == '-sverilog':
            # Not a no-op on the database: without it Surelog lexes a root
            # file that is not `.sv` in Verilog mode, and slang-uhdm models
            # that lexer (§ svModeAllFiles188 in uhdm_main.cpp). The flag
            # tells slang-uhdm that Surelog read every file as SystemVerilog.
            args.append('--sverilog')
        elif p == '-synth':
            args.append('--synth')
        elif p == '-formal':
            args.append('--formal')
        elif p == '-filterprotected':
            # Not a no-op: it drops `translate_off`..`translate_on` regions
            # and re-counts the lines after them (§ filterProtected120 and
            # § fpLineFiller120 in uhdm_main.cpp).  uhdm2rtlil's flow passes it.
            args.append('--filterprotected')
        elif p in ONEARG_MAP:
            args += [ONEARG_MAP[p], parts[i + 1]]
            i += 2
            continue
        elif p.startswith('-timescale='):
            args += ['--timescale', p.split('=', 1)[1]]
        elif p.startswith('--disable-feature=') or p.startswith('--enable-feature='):
            feats = [f for f in p.split('=', 1)[1].split(',') if f]
            if feats and all(f in IMPLEMENTED_FEATURES for f in feats):
                args.append(p)          # same spelling on both sides
            else:
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


def strict_verdict(golden, ours, timeout):
    """The `strict` column: uhdm-strictcmp on a CMP_EQUAL pair. 'equal' when
    every walked object matches on name, definition name, full name, file
    basename, span, decompile, size, value and constant type in the same
    order; else 'differ:<first differing field>(<objects differing>)'."""
    # 'equal' needs the comparator's own STRICT_EQUAL line: another binary at
    # STRICT_CMP (uhdm-cmp prints its usage and exits 0 on these arguments)
    # must not read every pair equal.
    try:
        r = subprocess.run([STRICT_CMP, '--max', '0', golden, ours], capture_output=True,
                           text=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        return 'timeout'
    if r.returncode == 0 and r.stdout.startswith('STRICT_EQUAL '):
        return 'equal'
    field, n = '', ''
    for line in r.stdout.splitlines():
        if line.startswith('STRICT_NOTEQUAL '):
            field = line.split(' ', 1)[1].strip()
        if 'objects_differing=' in line:
            n = line.split('objects_differing=')[1].split()[0]
    if r.returncode == 1:
        return 'differ:stage1'
    return f'differ:{field}({n})' if n else f'differ:{field or "?"}'


def compare(name, mode, dirpath, sl_args, su_args, workroot, timeout):
    # The corpora share test names (CaseInside, VarSelect, ...), so the workdir
    # must be disambiguated by the test's source dir or a stale slang.uhdm from
    # the other corpus silently un-rejects a SLANG_REJECT row.
    work = os.path.join(workroot, mode,
                        name + '-' + hashlib.sha1(dirpath.encode()).hexdigest()[:8])
    os.makedirs(work, exist_ok=True)

    # Golden side: cache first (immutable per Surelog binary + dir + argv).
    cdir = golden_cache_dir(dirpath, sl_args) if CACHE_ENABLED else None
    hit = cache_load(cdir) if cdir else None
    golden_uhdm = None
    golden_dumphash = None
    if hit:
        status_line, golden_uhdm, golden_dumphash = hit
        with open(os.path.join(work, 'cmds.txt'), 'wt') as f:
            f.write('surelog: (golden cache hit %s)\n' % cdir)
        if not golden_uhdm:
            st, _, det = status_line.partition('|')
            return (name, mode, st, det, '', '')
    else:
        # A database an earlier run left here would be taken for this run's
        # golden when Surelog writes none (find_uhdm globs the directory).
        for sub in ('slpp_all', 'slpp_unit'):
            shutil.rmtree(os.path.join(work, sub), ignore_errors=True)
        sl_argv = [SURELOG] + sl_args + ['-mt', '0', '-mp', '0', '-o', work]
        with open(os.path.join(work, 'cmds.txt'), 'wt') as f:
            f.write('surelog: ' + shlex.join(sl_argv) + '\n')
        try:
            sl = subprocess.run(sl_argv, cwd=dirpath, capture_output=True,
                                text=True, timeout=timeout)
        except subprocess.TimeoutExpired:
            return (name, mode, 'TIMEOUT', 'surelog timeout', '', '')

        uhdms = find_uhdm(work)
        if not uhdms:
            tail = (sl.stdout or sl.stderr or '').strip().splitlines()
            st = 'SURELOG_FAIL' if sl.returncode else 'NO_UHDM'
            det = tail[-1][:140] if tail else f'rc={sl.returncode}'
            if cdir:
                cache_store(cdir, None, st + '|' + det)
            return (name, mode, st, det, '', '')
        if len(uhdms) > 1:
            det = f'{len(uhdms)} databases (fileunit)'
            if cdir:
                cache_store(cdir, None, 'NO_UHDM|' + det)
            return (name, mode, 'NO_UHDM', det, '', '')
        golden_uhdm = uhdms[0]
        if cdir:
            cache_store(cdir, golden_uhdm, 'OK|')
            h2 = cache_load(cdir)
            if h2:
                golden_dumphash = h2[2]

    slang_out = os.path.join(work, 'slang.uhdm')
    # SLANG_REJECT classification keys on this file's ABSENCE — a leftover from
    # a prior run in a reused workdir would fake a live comparison.
    try:
        os.unlink(slang_out)
    except FileNotFoundError:
        pass
    su_argv = [SLANG_UHDM] + su_args + ['-o', slang_out]
    with open(os.path.join(work, 'cmds.txt'), 'at') as f:
        f.write('slang:   ' + shlex.join(su_argv) + '\n')
    try:
        su = subprocess.run(su_argv, cwd=dirpath, capture_output=True, text=True,
                            timeout=timeout)
    except subprocess.TimeoutExpired:
        return (name, mode, 'TIMEOUT', 'slang timeout', '', '')
    if not os.path.exists(slang_out):
        tail = (su.stderr or su.stdout or '').strip().splitlines()
        msg = next((l for l in tail if 'error' in l.lower()), tail[-1] if tail else '')
        return (name, mode, 'SLANG_REJECT', msg[:140] or f'rc={su.returncode}', '', '')

    try:
        cp = subprocess.run([UHDM_CMP, golden_uhdm, slang_out],
                            capture_output=True, text=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        return (name, mode, 'TIMEOUT', 'uhdm-cmp timeout', '', '')
    if cp.returncode != 0:
        # The dump column (byte identity, phase-3 metric) is only gate-relevant
        # on CMP_EQUAL rows (match->differ demotion). Dumping the slang side of
        # every not-equal test -- including the multi-million-line designs --
        # bought nothing; skipped, recorded as ''.
        tail = (cp.stdout or cp.stderr or '').strip().splitlines()
        return (name, mode, 'CMP_NOTEQUAL', tail[0][:140] if tail else '', '', '')
    strict = strict_verdict(golden_uhdm, slang_out, timeout)
    if strict == 'differ:stage1':
        # The strict comparator's stage 1 is uhdm-cmp's own Compare: a pair it
        # rejects is not judge-equal, whatever the binary at UHDM_CMP said.
        return (name, mode, 'CMP_NOTEQUAL', 'uhdm-strictcmp stage 1: not equal', '', '')
    if strict != 'equal':
        # The strict flip: judge-equal but not strict-equal.
        return (name, mode, 'STRICT_NOTEQUAL', strict, '', strict)
    return (name, mode, 'CMP_EQUAL', '', '', strict)


def run_one(name, dirpath, parts, modes, workroot, timeout):
    if name in DEFERRED_TESTS:
        return [(name, m, 'DEFERRED',
                 'late-phase: golden uncacheable on this machine', '', '')
                for m in modes if m != 'folded']
    sources, _options = split_sources(parts)
    results = []

    if 'default' in modes:
        # Both tools get the sources plus only the args saying where to find
        # them; no model-shaping flag on either side.  `-parse` is not a test
        # option, it is what makes Surelog emit a database at all.  Surelog's
        # default is one compilation unit, so slang needs --single-unit to match
        # that default, and Surelog's default also parses its builtin classes.
        loc, sl_only = location_args(parts)
        # Surelog's parse-mode switch `-sverilog` reaches slang-uhdm as
        # `--sverilog`: the golden is built with it, so slang-uhdm must not
        # model the Verilog-mode lexer for that test.
        su_mode = ['--sverilog'] if '-sverilog' in sl_only else []
        su = (su_mode + [LOCATION_RENAME.get(a, a) for a in loc] + list(sources) +
              ['--single-unit'])
        results.append(compare(name, 'default', dirpath,
                               ['-parse'] + precompiled_guard(sources) +
                               loc + sl_only + sources, su,
                               workroot, timeout))

    if 'folded' in modes and '-elabuhdm' in parts:
        su_args, blocking, nodb, nobuiltin = translate(parts)
        if not blocking and not nodb:
            if nobuiltin:
                su_args.append('--nobuiltin')
            sl_folded = (precompiled_guard(parts) +
                         [p for p in parts if p != '-elabuhdm'])
            su_folded = [a for a in su_args if a != '--elabuhdm']
            results.append(compare(name, 'folded', dirpath, sl_folded,
                                   su_folded, workroot, timeout))

    if 'testflags' in modes:
        su_args, blocking, nodb, nobuiltin = translate(parts)
        if nodb:
            results.append((name, 'testflags', 'NO_DATABASE',
                            'test suppresses UHDM output', ' '.join(nodb), ''))
        elif blocking:
            results.append((name, 'testflags', 'UNTRANSLATABLE',
                            'UHDM-relevant flag not implemented in slang-uhdm',
                            ' '.join(blocking), ''))
        else:
            if nobuiltin:
                su_args.append('--nobuiltin')
            results.append(compare(name, 'testflags', dirpath,
                                   precompiled_guard(parts) + parts, su_args,
                                   workroot, timeout))
    return results


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--corpus', choices=['surelog', 'uhdm2rtlil'], required=True)
    ap.add_argument('--mode', default='both',
                    choices=['default', 'testflags', 'folded', 'both', 'all'],
                    help="'both'=default+testflags; 'all' adds the folded overlay")
    ap.add_argument('--out', required=True)
    ap.add_argument('--workdir', default='/tmp/verify_golden')
    ap.add_argument('--jobs', type=int, default=4)
    ap.add_argument('--timeout', type=int, default=180)
    ap.add_argument('--filter', default=None)
    args = ap.parse_args()

    for env, tool in (('SURELOG', SURELOG), ('SLANG_UHDM', SLANG_UHDM),
                      ('UHDM_CMP', UHDM_CMP), ('UHDM_DUMP', UHDM_DUMP),
                      ('STRICT_CMP', STRICT_CMP)):
        if not os.path.exists(tool):
            sys.exit(f'missing tool: {tool} (set ${env}, or build the '
                     f'third_party/Surelog submodule / this tree; see tests/README.md)')
    for what, root in (('Surelog suite', os.path.join(SURELOG_ROOT, 'tests')),
                       ('uhdm2rtlil corpus', UHDM2RTLIL_TESTS)):
        if not os.path.isdir(root):
            sys.exit(f'missing {what}: {root} (git submodule update --init)')

    mode_sets = {'both': ['default', 'testflags'],
                 'all': ['default', 'testflags', 'folded']}
    modes = mode_sets.get(args.mode, [args.mode])
    tests = (discover_surelog(args.filter) if args.corpus == 'surelog'
             else discover_uhdm2rtlil(args.filter))
    print(f'{len(tests)} tests in {args.corpus}; modes={",".join(modes)}; '
          f'strict comparator {STRICT_CMP}', flush=True)
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
                             f'{exc}'[:140], '', ''))
            if done % 25 == 0:
                print(f'  {done}/{len(tests)}', flush=True)

    rows.sort(key=lambda r: (r[0].lower(), r[1]))
    with open(args.out, 'wt') as f:
        f.write('name,mode,status,detail,blocked_by,strict\n')
        for name, mode, status, detail, blocked, strict in rows:
            detail = detail.replace(',', ';').replace('\n', ' ')
            f.write(f'{name},{mode},{status},{detail},{blocked},{strict}\n')

    for mode in modes:
        counts = {}
        for _n, m, status, _d, _b, _dm in rows:
            if m == mode:
                counts[status] = counts.get(status, 0) + 1
        total = sum(counts.values())
        print(f'\n[{mode}] {total} tests')
        for k, v in sorted(counts.items(), key=lambda kv: -kv[1]):
            print(f'  {k}: {v}')


if __name__ == '__main__':
    main()
