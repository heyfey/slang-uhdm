#!/usr/bin/env python3
"""Build the census TSV: one row per corpus TEST-MODE, carrying the SLANG argv
verify_golden.py would hand the binary.

It imports verify_golden.py rather than re-deriving anything, so a census can
never be run against an argv the sweep would not have used -- that asymmetry is
the difference between a census and a guess.  DEFERRED tests are emitted too
(the census runs them; only the SWEEP defers them), and the four slang-fenced
names are dropped HERE as well as in the runner, belt and braces.

    usage: maketsv.py > /tmp/<pass>_tests.tsv
"""
import importlib.util
import os
import shlex
import sys

HOME = os.path.expanduser('~')
SPEC = os.path.join(HOME, 'git-repos', 'slang-uhdm', 'scripts', 'verify_golden.py')
spec = importlib.util.spec_from_file_location('vg', SPEC)
vg = importlib.util.module_from_spec(spec)
spec.loader.exec_module(vg)

FENCED = {'UnsignedParam', 'HierPathEval', 'FileLocalParam', 'TopParam'}

rows = []
for corpus, tests in (('surelog', vg.discover_surelog(None)),
                      ('uhdm2rtlil', vg.discover_uhdm2rtlil(None))):
    for name, (dirpath, parts) in sorted(tests.items()):
        if name in FENCED or name in vg.DEFERRED_TESTS:
            continue   # fenced by the standing rules / deferred by the sweep
        sources, _ = vg.split_sources(parts)
        loc, sl_only = vg.location_args(parts)
        su = ([vg.LOCATION_RENAME.get(a, a) for a in loc] + list(sources) +
              ['--single-unit'])
        rows.append((corpus, name, 'default', dirpath, su))
        su_args, blocking, nodb, nobuiltin = vg.translate(parts)
        if nodb or blocking:
            continue
        if nobuiltin:
            su_args.append('--nobuiltin')
        rows.append((corpus, name, 'testflags', dirpath, su_args))

for c, n, m, d, a in rows:
    # shlex.join, NOT ' '.join: DecValue's -GA="'d7_200" and BlackBoxInst's
    # --bb_inst work@top... both carry shell metacharacters, and the runner
    # word-splits this field.  An unquoted census argv is a DIFFERENT argv.
    sys.stdout.write('\t'.join([c, n, m, d, shlex.join(a)]) + '\n')
