#!/usr/bin/env python3
"""r10rgg15/predict15.py — PREDICT the mover set BY NAME from the PRISTINE
databases, before any patched run (rgg10's predictdb10.sh pattern).

The law this pass ships rewrites exactly ONE emitter site: the UNBASED-UNSIZED
override-actual `param_assign` Rhs mint (`ParamEmit.cpp` § unbasedOvConst).
Every constant that site makes is LOC-LESS today, so the candidate set is
MEASURED, not guessed: every `param_assign` Rhs constant in a PRISTINE OURS
database that carries no line number (`/LL`).  For each candidate the GOLDEN row
at the same key is printed beside it and classified, so a row that is ALREADY
EQUAL (the fence) is visible BEFORE the patch exists.

  usage: predict15.py <workdir> <outfile>

GUARDS: the golden path is read out of each test's own cmds.txt (so this can
never compare against the wrong golden); a missing side is COUNTED as
SKIP-NOFILE, never silently skipped; the FENCED tests are not dispatched here
(this reads databases an earlier sweep already wrote).
"""
import os, re, subprocess, sys, collections

CEN = os.environ.get('FCENSUS', '/tmp/r10rgg15_fcensus')


def census(path):
    out = subprocess.run([CEN, path], capture_output=True, text=True,
                         errors='replace')
    d = {}
    for ln in out.stdout.splitlines():
        k, _, v = ln.partition('\t')
        d.setdefault(k, []).append(v)
    return d


def main(wd, outp):
    tot = miss = hit = 0
    fams = collections.Counter()
    with open(outp, 'wt') as f:
        for mode in sorted(os.listdir(wd)):
            md = os.path.join(wd, mode)
            if not os.path.isdir(md):
                continue
            for t in sorted(os.listdir(md)):
                d = os.path.join(md, t)
                c = os.path.join(d, 'cmds.txt')
                o = os.path.join(d, 'slang.uhdm')
                if not os.path.isfile(c):
                    continue
                tot += 1
                m = re.search(r'golden cache hit (/[^)]*)', open(c).read())
                g = os.path.join(m.group(1), 'golden.uhdm') if m else None
                if not g or not os.path.isfile(g) or not os.path.isfile(o):
                    miss += 1
                    continue
                oc = census(o)
                cand = {k: vs for k, vs in oc.items()
                        if any('/LL' in v.split('\t')[0] for v in vs)}
                if not cand:
                    continue
                gc = census(g)
                for k in sorted(cand):
                    for v in cand[k]:
                        if '/LL' not in v.split('\t')[0]:
                            continue
                        gv = gc.get(k, ['<absent>'])
                        gs = gv[0].split('\t')[0]
                        os_ = v.split('\t')[0]
                        eq = 'EQUAL-SHAPE' if gs.split(')')[0] == os_.split(')')[0] \
                            else 'DIFF'
                        f.write('%s/%s\t%s\n\tG %s\n\tO %s\t[%s]\n'
                                % (mode, t, k, gv[0], v, eq))
                        fams[(gs, os_, eq)] += 1
                        hit += 1
        f.write('\n== FAMILIES ==\n')
        for (gs, os_, eq), n in fams.most_common():
            f.write('%5d %-11s G %-52s O %s\n' % (n, eq, gs, os_))
    print('TESTS=%d SKIP-NOFILE=%d CANDIDATE-ROWS=%d -> %s'
          % (tot, miss, hit, outp))
    for (gs, os_, eq), n in fams.most_common(20):
        print('%5d %-11s G %-52s O %s' % (n, eq, gs, os_))


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
