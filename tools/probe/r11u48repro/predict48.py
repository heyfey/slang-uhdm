#!/usr/bin/env python3
"""r11u48 — THE A PRIORI MOVER PREDICTION, off the PRISTINE corpus.

Re-runs every arm of a PRISTINE workdir with the PATCHED binary under

  R11U48_OFF=1  the NEUTRAL build: its database must be BYTE-IDENTICAL to the
                pristine one (the positive control that the instrument is
                wired up at all -- a neutral run that DIFFERS means the law
                leaked into the off path);
  R11U48_DBG=1  which names on stderr every cell whose answer the law CHANGES
                (R11U48A = a call argument that loses its formal-typespec ref,
                 R11U48B = a folded range bound whose ts ref presence/sign
                 changes).

So the mover set is known BY NAME before the patched sweep runs.

  predict48.py <pristine-workdir> <patched-binary> <out-dir>

The command line is taken from each arm's own cmds.txt VERBATIM (binary and
-o path swapped), and the cwd is recovered from the arm directory name, which
the harness builds as `<test>-<sha1(dirpath)[:8]>`.
"""
import hashlib
import os
import re
import shlex
import subprocess
import sys

HOME = os.path.expanduser('~')
SURELOG_ROOT = os.path.join(HOME, 'git-repos', 'Surelog')
U2R = os.path.join(HOME, 'git-repos', 'uhdm2rtlil', 'test')


def candidate_dirs():
    """Every directory the two corpora can name, keyed by sha1[:8]."""
    out = {}
    for name in os.listdir(U2R):
        d = os.path.join(U2R, name)
        if os.path.isdir(d):
            out[hashlib.sha1(d.encode()).hexdigest()[:8]] = d
    for root in (os.path.join(SURELOG_ROOT, 'tests'),
                 os.path.join(SURELOG_ROOT, 'third_party', 'tests')):
        for dirpath, _dirs, files in os.walk(root):
            if any(f.endswith('.sl') for f in files):
                out[hashlib.sha1(dirpath.encode()).hexdigest()[:8]] = dirpath
    return out


def main():
    wd, law, outdir = sys.argv[1], sys.argv[2], sys.argv[3]
    os.makedirs(outdir, exist_ok=True)
    dirs = candidate_dirs()
    neutral = open(os.path.join(outdir, 'neutral.tsv'), 'wt')
    predict = open(os.path.join(outdir, 'predict.tsv'), 'wt')
    n = same = differ = nodb = nocwd = 0
    for root, _d, files in os.walk(wd):
        if 'cmds.txt' not in files:
            continue
        arm = os.path.basename(root)
        mode = os.path.basename(os.path.dirname(root))
        test, _, h = arm.rpartition('-')
        db = os.path.join(root, 'slang.uhdm')
        if not os.path.isfile(db):
            nodb += 1
            continue
        cwd = dirs.get(h)
        if not cwd:
            nocwd += 1
            neutral.write('%s\t%s\tNOCWD\t-\n' % (test, mode))
            continue
        line = ''
        for raw in open(os.path.join(root, 'cmds.txt')):
            if raw.startswith('slang:'):
                line = raw.split(':', 1)[1].strip()
                break
        if not line:
            continue
        # shlex, not split(): the Surelog corpus has quoted arguments
        # (BlackBoxInst's `--bb_inst 'work@top.nyuzi.core_gen[0]'`), and a
        # naive split keeps the quotes, changes the flag's value and makes the
        # NEUTRAL column read DIFFER for a reason that has nothing to do with
        # the law.
        argv = shlex.split(line)
        nout = os.path.join(outdir, 'n_%s_%s.uhdm' % (mode, arm))
        argv = [law] + [nout if a == db else a for a in argv[1:]]
        env = dict(os.environ, R11U48_OFF='1', R11U48_DBG='1')
        if os.path.exists(nout):
            os.remove(nout)
        p = subprocess.run(argv, cwd=cwd, env=env, capture_output=True,
                           text=True, timeout=900)
        n += 1
        if os.path.isfile(nout):
            a = hashlib.md5(open(db, 'rb').read()).hexdigest()
            b = hashlib.md5(open(nout, 'rb').read()).hexdigest()
            verdict = 'SAME' if a == b else 'DIFFER'
            if a == b:
                same += 1
            else:
                differ += 1
            os.remove(nout)
        else:
            verdict = 'NODB'
            nodb += 1
        neutral.write('%s\t%s\t%s\trc=%d\n' % (test, mode, verdict, p.returncode))
        for ln in p.stderr.splitlines():
            if re.match(r'^R11U48[AB] ', ln):
                predict.write('%s\t%s\t%s\n' % (test, mode, ln))
    neutral.close()
    predict.close()
    print('PROCESSED %d  SAME %d  DIFFER %d  NODB %d  NOCWD %d'
          % (n, same, differ, nodb, nocwd))


main()
