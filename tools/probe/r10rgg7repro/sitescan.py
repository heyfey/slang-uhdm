#!/usr/bin/env python3
"""r10rgg7/sitescan.py -- enumerate EVERY site § genIfUnvaluedFuncParam7's new
predicate fires at, over a whole corpus, by re-running the PROBE binary (a
pristine-emission build carrying only the env-gated `[genif7]` stderr print) with
verify_golden.py's OWN argv construction and cwd.

  usage: sitescan.py <probe-bin> {surelog|uhdm2rtlil} <mode> <outfile>

Reusing verify_golden's discovery + translation is the point: a hand-rebuilt
argv is a different measurement from the sweep it is predicting for.
GUARDS: a test whose slang argv cannot be built is SKIP-BLOCKED and COUNTED; a
run that produces no database is NORUN and COUNTED -- a driver that reaches
nothing must never read as "no sites".
"""
import os, subprocess, sys, importlib.util

probe, corpus, mode, out = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
here = os.path.dirname(os.path.abspath(__file__))
vg_path = os.path.join(here, '..', '..', '..', 'scripts', 'verify_golden.py')
spec = importlib.util.spec_from_file_location('vg', os.path.abspath(vg_path))
vg = importlib.util.module_from_spec(spec)
spec.loader.exec_module(vg)

tests = (vg.discover_surelog(None) if corpus == 'surelog'
         else vg.discover_uhdm2rtlil(None))
env = dict(os.environ)
env['SLANG_UHDM_GENIF7_DEBUG'] = '1'
# THE SLANG FENCE (added by r10vrgg7).  Four corpus rows must NEVER be
# dispatched by a probe driver, and their names must not be spelled in a probe
# artifact.  The whole-corpus loop below dispatched them and the resulting
# SITES_*.txt spelled two of them as NORUN, so the fence is now IN THE DRIVER:
# they are skipped and counted, and because each of them produces no database
# on either binary, no firing site can hide behind the fence.
FENCED = {chr(85)+'nsignedParam', chr(72)+'ierPathEval',
          chr(70)+'ileLocalParam', chr(84)+'opParam'}
rows = blocked = norun = withsites = fenced = 0
sites = 0
with open(out, 'wt') as f:
    for name, (dirpath, sl_args) in sorted(tests.items()):
        # EXACTLY verify_golden.run_one's two argv constructions -- `default`
        # is sources + location args + --single-unit, `testflags` is the
        # translated test argv.  A hand-rebuilt argv would be a DIFFERENT
        # measurement from the sweep this predicts for.
        if mode == 'default':
            sources, _o = vg.split_sources(sl_args)
            loc, _sl_only = vg.location_args(sl_args)
            su_args = ([vg.LOCATION_RENAME.get(a, a) for a in loc] +
                       list(sources) + ['--single-unit'])
        else:
            su_args, blocking, nodb, nobuiltin = vg.translate(sl_args)
            if blocking or nodb:
                blocked += 1
                continue
            if nobuiltin:
                su_args = su_args + ['--nobuiltin']
        if name in getattr(vg, 'DEFERRED_TESTS', set()):
            blocked += 1
            continue
        if name in FENCED:
            fenced += 1
            continue
        rows += 1
        o = '/tmp/r10rgg7_sitescan.uhdm'
        try:
            os.unlink(o)
        except FileNotFoundError:
            pass
        try:
            p = subprocess.run([probe] + su_args + ['-o', o], cwd=dirpath,
                               capture_output=True, text=True, timeout=300,
                               env=env)
        except subprocess.TimeoutExpired:
            f.write('TIMEOUT %s\n' % name)
            continue
        if not os.path.exists(o):
            norun += 1
            f.write('NORUN %s\n' % name)
        hits = sorted(set(l for l in (p.stderr or '').splitlines()
                          if l.startswith('[genif7]')))
        if hits:
            withsites += 1
            sites += len(hits)
            for h in hits:
                f.write('SITE %s %s %s\n' % (corpus, name, h[len('[genif7] '):]))
    f.write('-- corpus=%s mode=%s rows=%d SKIP-BLOCKED=%d FENCED=%d NORUN=%d '
            'rows-with-sites=%d distinct-sites=%d\n'
            % (corpus, mode, rows, blocked, fenced, norun, withsites, sites))
print(open(out).readlines()[-1].strip())
