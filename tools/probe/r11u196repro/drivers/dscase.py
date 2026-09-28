#!/usr/bin/env python3
"""r11u196: the downstream verdict of every case dir given, per binary, with the gate's own one() (the surelog lane uses
uhdm2rtlil's own Surelog with the downstream flags, the slang lane the translated command line).  The case path must
not name a fenced test ($FENCED from the FENCED= line of tools/probe/r11u107repro/canaudit.sh, fail closed).  A fresh
GOLDEN_CACHE (argument 1) keys the case goldens.   usage: dscase.py <golden cache dir> <work root> <out.tsv> <binary>... -- <case dir>..."""
import sys, os, re
H = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(H, '..', '..', '..', '..'))
line = [l for l in open(os.path.join(REPO, 'tools/probe/r11u107repro/canaudit.sh')) if l.startswith('FENCED=')][0]
F = line.split('=', 1)[1].strip().strip('"\'').split()
assert len(F) == 4, 'fence unreadable'
gc, wr, out = sys.argv[1:4]
rest = sys.argv[4:]; k = rest.index('--'); bins, cases = rest[:k], rest[k + 1:]
os.environ['GOLDEN_CACHE'] = gc
sys.path.insert(0, os.path.join(REPO, 'scripts'))
for c in cases:
    assert not any(re.search(r'\b%s\b' % re.escape(f), c) for f in F), 'fenced case refused'
rows = []
def run(b, c):
    os.environ['SLANG_UHDM'] = b
    import importlib, verify_golden as vg, downstream_uhdm2rtlil as ds
    importlib.reload(vg)   # vg.SLANG_UHDM is read at import: reload it, then the harness
    importlib.reload(ds)
    assert vg.SLANG_UHDM == b and ds.vg.SLANG_UHDM == b, 'binary not taken'
    src = [f for f in ('dut.sv',) if os.path.exists(os.path.join(c, f))]
    parts = ['-parse', '-nobuiltin', '-nocache', '-sv'] + (open(os.path.join(c, 'args')).read().split() if os.path.exists(os.path.join(c, 'args')) else
            open(os.path.join(c, 'files')).read().split() if os.path.exists(os.path.join(c, 'files')) else src)
    name = os.path.relpath(c, os.path.join(H, '..', 'cases')).replace('/', '__')
    r = ds.one(name, os.path.abspath(c), parts, os.path.join(wr, os.path.basename(b)), 300)
    return [os.path.basename(b), name, r['verdict'], r['surelog_status'], r['slang_status'], r['differs'], r['detail'][:80]]
for b in bins:
    for c in cases:
        rows.append(run(b, c))
        print('\t'.join(rows[-1]), flush=True)
with open(out, 'w') as f:
    for r in rows: f.write('\t'.join(r) + '\n')
