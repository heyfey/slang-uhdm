#!/usr/bin/env python3
"""predict_fix.py <out.txt>: the fix's mover PREDICTION by source shape, run BEFORE the fix sweep (wide on
purpose): a corpus test can move only if its sources hold a modport and a port connection whose actual is a
member with ONE select (`.p(x.m[...])`, § ifaceSigConnSelectWrites162v) or a macro use (`.p(`M...)`,
§ ifaceSigConnLastByExpansion162v).  Fail-closed on $FENCED: refuses to run without it and never opens a
fenced test's directory (word match)."""
import os, re, sys, glob
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4: sys.exit('predict_fix.py: export FENCED (drivers/env.sh) first')
SL = os.environ['SURELOG_ROOT']; U2R = os.environ['UHDM2RTLIL_TESTS']
def fenced(n): return any(re.search(r'\b%s\b' % re.escape(f), n) for f in FENCED)
def tests():
    for base in (os.path.join(SL, 'tests'), os.path.join(SL, 'third_party', 'tests')):
        for d in sorted(glob.glob(os.path.join(base, '*'))):
            if os.path.isdir(d) and glob.glob(os.path.join(d, '*.sl')): yield 'surelog', os.path.basename(d), d
    for d in sorted(glob.glob(os.path.join(U2R, '*'))):
        if os.path.isdir(d): yield 'uhdm2rtlil', os.path.basename(d), d
def text(d):
    out = []
    for r, _, fs in os.walk(d):
        for f in fs:
            if f.endswith(('.sv', '.v', '.svh', '.vh', '.inc', '.svi', '.sl', '.f')):
                try: out.append(open(os.path.join(r, f), errors='replace').read())
                except OSError: pass
    return '\n'.join(out)
SEL = re.compile(r'\.\s*\w+\s*\(\s*\w+\s*\.\s*\w+\s*\[[^\]]*\]\s*\)')
MAC = re.compile(r'\.\s*\w+\s*\(\s*`\w+')
n = 0; hits = []
for c, name, d in tests():
    if fenced(name): continue
    n += 1; t = text(d)
    if 'modport' not in t: continue
    s, m = bool(SEL.search(t)), bool(MAC.search(t))
    if s or m: hits.append(f'{c} {name} {"SEL" if s else ""}{"+" if s and m else ""}{"MAC" if m else ""}')
open(sys.argv[1], 'w').write(f'# scanned {n} tests (fenced skipped); tests with a modport and a select/macro actual: {len(hits)}\n' + '\n'.join(hits) + '\n')
print('scanned', n, 'candidates', len(hits))
