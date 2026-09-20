#!/usr/bin/env python3
"""r11u69 SITE CENSUS — name EVERY generate-scope cont_assign in a corpus that
reaches this law's site, with the predicate's answer AND each gate's.

It replays the harness's OWN discovery and its OWN slang argument vector (the
same `discover_*` / `run_one` code path `scripts/verify_golden.py` uses, so a
site cannot be missed because a driver spelled a flag differently), runs the
PATCHED binary with `R11U69_CELLDBG=1`, and writes one row per cell:

    test  mode  scope:offset  plainLhs  genLocal  iface  sps  rhsPre

Unlike a golden-vs-ours SHAPE census this also names the cells the law
DECLINES, which is what answers "did a gate fence out a corpus site?".
Every invocation's rc is recorded; a compile that fails teaches error-recovery,
not golden, and its row says so.

usage: cellcen69.py <slang-uhdm-repo> <corpus> <patched-binary> <out.tsv>
"""
import os
import subprocess
import sys

REPO, CORPUS, BIN, OUT = sys.argv[1:5]
sys.path.insert(0, os.path.join(REPO, 'scripts'))
os.environ.setdefault('SLANG_UHDM', BIN)
import verify_golden as vg          # noqa: E402

vg.SLANG_UHDM = BIN

tests = (vg.discover_surelog(None) if CORPUS == 'surelog'
         else vg.discover_uhdm2rtlil(None))

# The harness's own deferred set, PLUS the four slang-fenced names, which this
# driver must never dispatch.  They are read out of the canary auditor's own
# `FENCED=` line rather than written here, so the auditor stays the one place
# that spells them and `canaudit.sh` keeps passing over this directory.
FENCED = set(getattr(vg, 'DEFERRED_TESTS', set()))
with open(os.path.join(REPO, 'tools', 'probe', 'r10sd4repro',
                       'canaudit.sh')) as _f:
    for _l in _f:
        if _l.startswith('FENCED='):
            FENCED |= set(_l.split('=', 1)[1].strip().strip('"').split())
            break


def su_vectors(parts):
    """The harness's own slang argv per mode, minus the -o it appends."""
    out = []
    sources, _ = vg.split_sources(parts)
    loc, _sl_only = vg.location_args(parts)
    out.append(('default',
                [vg.LOCATION_RENAME.get(a, a) for a in loc] + list(sources) +
                ['--single-unit']))
    su_args, blocking, nodb, nobuiltin = vg.translate(parts)
    if not nodb and not blocking:
        if nobuiltin:
            su_args = su_args + ['--nobuiltin']
        out.append(('testflags', su_args))
    return out


rows = 0
with open(OUT, 'wt') as f:
    for name in sorted(tests):
        dirpath, parts = tests[name]
        if name in FENCED:
            continue
        for mode, argv in su_vectors(parts):
            try:
                p = subprocess.run([BIN] + argv + ['-o', '/dev/null'],
                                   cwd=dirpath, capture_output=True, text=True,
                                   timeout=180,
                                   env=dict(os.environ, R11U69_CELLDBG='1'))
                rc, err = p.returncode, p.stderr
            except subprocess.TimeoutExpired:
                rc, err = 'TIMEOUT', ''
            hits = [l for l in err.split('\n') if l.startswith('R11U69CELL')]
            for l in hits:
                f.write(f'{name}\t{mode}\trc={rc}\t{l}\n')
                rows += 1
            if not hits:
                f.write(f'{name}\t{mode}\trc={rc}\tNO-GEN-SCOPE-CA\n')
print(f'{OUT}: {rows} cell rows')
