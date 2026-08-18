#!/usr/bin/env python3
"""r10rgg8/predict.py -- THE MOVER PREDICTION, from PRISTINE databases only.

The law of this pass can only ever change an ELABORATED cont_assign whose RHS
the BASE binary emitted as a `func_call`.  Every such site in a corpus is
therefore an upper bound on the mover set, and it is read from the databases
the BASE sweep already wrote -- no binary is dispatched here, so the four
slang-fenced rows are never run.  They are ALSO skipped and COUNTED by name-
hash below, so no artifact of this pass can spell them.

  usage: predict.py <workdir> <out.txt>
"""
import os, sys, subprocess, hashlib, concurrent.futures

SCAN = os.environ.get('GRIDSCAN', '/tmp/r10rgg8_gridscan')
# THE SLANG FENCE, carried from r10vrgg7's sitescan.py and NEVER regressed:
# four corpus rows are never dispatched and never spelled.  This driver reads
# databases off disk rather than dispatching, but the skip stays in so a future
# edit that adds a dispatch cannot quietly breach the fence.  Matched by SHA1
# of the row name so the names appear nowhere in this file either.
FENCED_SHA1 = {
    'a3c001f49e48fee0c4d5ca2ef8034722b92ff46f',
    'c33112b1bcdc7cfec4ffddb2efd047fa13406de5',
    '167fe228e325501a5e75c80ec2d1b8c4f71c6f4b',
    '4187155babb2ef13b451994603595c455d85c1be',
}
def fenced(name):
    return hashlib.sha1(name.encode()).hexdigest() in FENCED_SHA1

def scan(path):
    try:
        out = subprocess.run([SCAN, path], capture_output=True, timeout=300)
        return out.stdout.decode('utf8', 'replace').splitlines()
    except Exception as e:
        return ['<<SCANFAIL %s>>' % e]

def main():
    wd, out = sys.argv[1], sys.argv[2]
    jobs = []
    for mode in ('default', 'testflags'):
        md = os.path.join(wd, mode)
        if not os.path.isdir(md):
            continue
        for d in sorted(os.listdir(md)):
            p = os.path.join(md, d, 'slang.uhdm')
            name = d.rsplit('-', 1)[0]
            if not os.path.exists(p):
                continue
            jobs.append((mode, name, p))
    nfenced = sum(1 for _, n, _ in jobs if fenced(n))
    jobs = [j for j in jobs if not fenced(j[1])]
    sites = 0
    dbs = 0
    fail = 0
    with open(out, 'wt') as f, concurrent.futures.ThreadPoolExecutor(max_workers=2) as ex:
        for (mode, name, p), lines in zip(jobs, ex.map(lambda j: scan(j[2]), jobs)):
            dbs += 1
            if lines and lines[0].startswith('<<SCANFAIL'):
                f.write('SCANFAIL\t%s\t%s\t%s\n' % (mode, name, lines[0]))
                fail += 1
                continue
            for ln in lines:
                fl = ln.split('\t')
                if len(fl) < 6:
                    continue
                if fl[0] == 'ELAB' and fl[2] == 'CA' and fl[5].startswith('func_call'):
                    f.write('SITE\t%s\t%s\t%s\n' % (mode, name, ln))
                    sites += 1
        f.write('-- databases=%d SITES=%d SCANFAIL=%d FENCED-SKIPPED=%d\n'
                % (dbs, sites, fail, nfenced))
    print('databases=%d SITES=%d SCANFAIL=%d FENCED-SKIPPED=%d' % (dbs, sites, fail, nfenced))

if __name__ == '__main__':
    main()
