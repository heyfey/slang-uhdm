#!/usr/bin/env python3
"""v11u224: downstream verdicts of case dirs (dut.sv) with the pristine and the law binary, through
scripts/downstream_uhdm2rtlil.py's one() (the Surelog lane: uhdm2rtlil's own Surelog with the downstream flags; the
slang lane: the translated command line).  dsgrid.py <list of case dirs> <workroot>: per case, P and L verdicts and
whether the two slang lanes' _nohier.il are byte-identical.  Case dirs only (never a corpus test); fail-closed on $FENCED."""
import os, re, sys, filecmp
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('dsgrid.py: source drivers/env.sh first')
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import downstream_uhdm2rtlil as ds
B = os.environ['B']
cases = [l.strip() for l in open(sys.argv[1]) if l.strip()]
wr = sys.argv[2]
for c in cases:
    if any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', c) for f in F): print(c, 'FENCED'); continue
    name = re.sub(r'.*/cases/', '', c).replace('/', '_')
    res = {}
    for tag, b in (('P', 'pristine.bin'), ('L', os.environ.get('LAWBIN', 'law.bin'))):
        ds.vg.SLANG_UHDM = os.path.join(B, b)
        r = ds.one(name, c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], os.path.join(wr, tag), 300)
        res[tag] = r
    nh = [os.path.join(wr, t, name, 'slanguh', f'{name}_nohier.il') for t in 'PL']
    same = 'nohier_same' if all(os.path.exists(x) for x in nh) and filecmp.cmp(nh[0], nh[1], shallow=False) else 'nohier_moved'
    print(f"{name} P:{res['P']['verdict']}({res['P']['differs']}) L:{res['L']['verdict']}({res['L']['differs']}) {same}", flush=True)
