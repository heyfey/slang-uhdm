#!/usr/bin/env python3
"""r10rgg8/sitescan.py -- EVERY FIRING SITE of § srlgUnvaluedActualLitRetFold8
over a corpus.

  usage: sitescan.py <patched-workdir> <out.txt> [<candidates.txt> ...]

THE ARGV IS NOT REBUILT.  Each row's `cmds.txt`, written by verify_golden.py
itself during the sweep, carries the EXACT `slang:` command line that produced
the database being gated; this driver re-runs THAT line with
SLANG_UHDM_RGG8_SITES=1 and collects the decision-point prints.  A hand-rebuilt
argv would be a different measurement from the sweep it explains.

Only rows carrying a CANDIDATE site are dispatched: the law can change nothing
but the vpiRhs of an ELABORATED cont_assign the BASE binary emitted as a
`func_call`, and predict.py enumerated every such row off the pristine base
databases.  Rows without one are INCAPABLE of firing; they are skipped and
COUNTED.

THE SLANG FENCE (carried from r10vrgg7's sitescan.py, never regressed): four
corpus rows are never dispatched by a probe driver and never spelled in a probe
artifact.  Matched by SHA1 so this file does not spell them; counted so the skip
is visible.  They hold no candidate site either, so no firing site can hide
behind the fence.
"""
import os, sys, subprocess, hashlib, shlex, importlib.util

wd, out = sys.argv[1], sys.argv[2]
cands = sys.argv[3:]

# The source directory each row is run FROM -- verify_golden.py's own discovery,
# so the cwd is the sweep's, not a guess.
_vg = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                   '..', '..', '..', 'scripts', 'verify_golden.py')
_spec = importlib.util.spec_from_file_location('vg', os.path.abspath(_vg))
vg = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(vg)
DIRS = {}
for _disc in (vg.discover_surelog, vg.discover_uhdm2rtlil):
    for _n, (_dp, _a) in _disc(None).items():
        DIRS.setdefault(_n, _dp)

FENCED_SHA1 = {
    'a3c001f49e48fee0c4d5ca2ef8034722b92ff46f',
    'c33112b1bcdc7cfec4ffddb2efd047fa13406de5',
    '167fe228e325501a5e75c80ec2d1b8c4f71c6f4b',
    '4187155babb2ef13b451994603595c455d85c1be',
}
def is_fenced(n):
    return hashlib.sha1(n.encode()).hexdigest() in FENCED_SHA1

want = set()
for c in cands:
    for ln in open(c):
        f = ln.split('\t')
        if len(f) > 2 and f[0] == 'SITE':
            want.add((f[1], f[2]))

env = dict(os.environ)
env['SLANG_UHDM_RGG8_SITES'] = '1'
rows = skipped = fenced = norun = withsites = sites = nocmd = 0
with open(out, 'wt') as f:
    for mode in ('default', 'testflags'):
        md = os.path.join(wd, mode)
        if not os.path.isdir(md):
            continue
        for d in sorted(os.listdir(md)):
            name = d.rsplit('-', 1)[0]
            if is_fenced(name):
                fenced += 1
                continue
            if want and (mode, name) not in want:
                skipped += 1
                continue
            cp = os.path.join(md, d, 'cmds.txt')
            if not os.path.exists(cp):
                nocmd += 1
                continue
            line = None
            for ln in open(cp):
                if ln.startswith('slang:   '):
                    line = ln[len('slang:   '):].strip()
            if not line:
                nocmd += 1
                continue
            rows += 1
            argv = shlex.split(line)
            # The source directory is the golden run's cwd; recover it from the
            # surelog line when present, else from the first existing source.
            cwd = DIRS.get(name)
            try:
                r = subprocess.run(argv, env=env, capture_output=True, timeout=300,
                                   cwd=cwd)
            except Exception as e:
                f.write('NORUN\t%s\t%s\t%s\n' % (mode, name, e))
                norun += 1
                continue
            hits = [l for l in r.stderr.decode('utf8', 'replace').splitlines()
                    if l.startswith('[rgg8] SITE')]
            if hits:
                withsites += 1
                for h in sorted(set(hits)):
                    f.write('SITE\t%s\t%s\t%s\n' % (mode, name, h))
                    sites += 1
    f.write('-- dispatched=%d SKIPPED-NO-CANDIDATE=%d FENCED=%d NORUN=%d '
            'NO-CMDS=%d rows-with-sites=%d distinct-sites=%d\n'
            % (rows, skipped, fenced, norun, nocmd, withsites, sites))
print(open(out).read().strip().splitlines()[-1])
