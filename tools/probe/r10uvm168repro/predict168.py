#!/usr/bin/env python3
"""r10uvm168 — THE A-PRIORI MOVER PREDICTION.  MEASUREMENT ONLY.

  predict168.py <corpus:surelog|uhdm2rtlil> <binary> <out.txt>

Re-runs the emitter over every comparable row of a corpus with
`R10E168_DBG=1`, collecting every § enumOriginConstTypeIsTheMemberValue168
firing and the before/after const type it reports.  Run it with `R10E168_OFF=1`
in the environment and the binary behaves EXACTLY as the pristine one does, so
the firing list is a prediction of the mover set made BEFORE the law is allowed
to move anything (RESUME §6: "PREDICT the mover set BY NAME from pristine
databases FIRST").

WHY THIS IS A PYTHON SCRIPT AND NOT A `cmds.txt` REPLAY.  The recorded slang
command line names its sources RELATIVE to the test's own directory, which
`cmds.txt` does not record; a replay that guesses the cwd runs nothing and
reports zero firings — indistinguishable from a clean prediction.  So this
imports `scripts/verify_golden.py` and uses the HARNESS'S OWN discovery and
argument translation, and asserts a nonzero produced-database count.

Every rc is recorded.  The four slang-fenced tests are never dispatched: the
fence is applied by NAME PREFIX from an env list the caller supplies
(`FENCED=`), and the skipped count is printed, so a fence can never silently
become a filter that hides half the corpus.
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import verify_golden as VG  # noqa: E402


def main():
    if len(sys.argv) < 4:
        print('usage: predict168.py <corpus> <binary> <out.txt>')
        return 2
    corpus, binary, out = sys.argv[1], sys.argv[2], sys.argv[3]
    if not os.access(binary, os.X_OK):
        print('FATAL no binary', binary)
        return 3
    fenced = [f for f in os.environ.get('FENCED', '').split(',') if f]
    tests = (VG.discover_surelog(None) if corpus == 'surelog'
             else VG.discover_uhdm2rtlil(None))
    scratch = os.environ.get('SCRATCH', '/tmp/r10uvm168_predict_scratch')
    os.makedirs(scratch, exist_ok=True)
    env = dict(os.environ)
    env['R10E168_DBG'] = '1'
    rows = produced = skipped = fencedn = 0
    rcs = {}
    firings = []
    for name, (dirpath, parts) in sorted(tests.items()):
        if name in fenced:
            fencedn += 1
            continue
        if name in VG.DEFERRED_TESTS:
            skipped += 1
            continue
        sources, _ = VG.split_sources(parts)
        argvs = []
        loc, _sl_only = VG.location_args(parts)
        argvs.append(('default',
                      [VG.LOCATION_RENAME.get(a, a) for a in loc] +
                      list(sources) + ['--single-unit']))
        su_args, blocking, nodb, nobuiltin = VG.translate(parts)
        if not blocking and not nodb:
            if nobuiltin:
                su_args = su_args + ['--nobuiltin']
            argvs.append(('testflags', su_args))
        for mode, args in argvs:
            o = os.path.join(scratch, '%s.%s.uhdm' % (name, mode))
            try:
                p = subprocess.run([binary] + args + ['-o', o], cwd=dirpath,
                                   capture_output=True, text=True, timeout=900,
                                   env=env, stdin=subprocess.DEVNULL)
            except subprocess.TimeoutExpired:
                rcs['timeout'] = rcs.get('timeout', 0) + 1
                rows += 1
                continue
            rcs[p.returncode] = rcs.get(p.returncode, 0) + 1
            if os.path.exists(o):
                produced += 1
                os.unlink(o)
            for ln in (p.stderr or '').splitlines():
                if ln.startswith('R10E168 '):
                    firings.append('%s/%s %s' % (mode, name, ln))
            rows += 1
    with open(out, 'wt') as f:
        f.write('PREDICT binary=%s env_off=%s\n' %
                (binary, os.environ.get('R10E168_OFF', '<unset>')))
        for ln in firings:
            f.write(ln + '\n')
        f.write('PREDICTRUN corpus=%s rows=%d produced=%d skipped=%d '
                'fenced=%d firings=%d\n' %
                (corpus, rows, produced, skipped, fencedn, len(firings)))
        f.write('RC %s\n' % sorted(rcs.items(), key=lambda kv: str(kv[0])))
    print(open(out).readlines()[-2].strip())
    print(open(out).readlines()[-1].strip())
    if produced == 0:
        print('FATAL: the prediction run produced NO databases — a zero '
              'firing count here would be meaningless')
        return 4
    return 0


if __name__ == '__main__':
    sys.exit(main())
