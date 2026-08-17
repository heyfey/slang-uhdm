"""r10buvm4 census enumerator.

Prints ONE tab-separated row per (corpus, test, mode) with the test's own
directory and the EXACT slang argv verify_golden.py would hand the emitter --
built by importing verify_golden and calling its OWN translate() /
location_args() / split_sources(), so the census can never be run on flags the
sweep would not use.  DEFERRED tests and testflags rows verify_golden classes
NO_DATABASE / UNTRANSLATABLE are dropped and reported on stderr.

  usage: SLANG_UHDM_REPO=<repo> python3 censusenum.py > tests.tsv
"""
import sys, os, shlex
REPO = os.environ.get('SLANG_UHDM_REPO',
                      os.path.expanduser('~/git-repos/slang-uhdm'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import verify_golden as V
rows = []
for name, (dirpath, parts) in V.discover_surelog('').items():
    rows.append(('surelog', name, dirpath, parts))
for name, (dirpath, parts) in V.discover_uhdm2rtlil('').items():
    rows.append(('u2r', name, dirpath, parts))
n = 0
for corpus, name, dirpath, parts in rows:
    if name in V.DEFERRED_TESTS:
        print('#DEFERRED\t%s\t%s' % (corpus, name), file=sys.stderr)
        continue
    sources, _o = V.split_sources(parts)
    loc, sl_only = V.location_args(parts)
    su = [V.LOCATION_RENAME.get(a, a) for a in loc] + list(sources) + ['--single-unit']
    print('\t'.join([corpus, name, 'default', dirpath, shlex.join(su)]))
    su_args, blocking, nodb, nobuiltin = V.translate(parts)
    if nodb or blocking:
        print('#SKIP-TF\t%s\t%s\t%s' % (corpus, name, blocking or nodb), file=sys.stderr)
    else:
        if nobuiltin:
            su_args.append('--nobuiltin')
        print('\t'.join([corpus, name, 'testflags', dirpath, shlex.join(su_args)]))
    n += 1
print('#TESTS %d' % n, file=sys.stderr)
