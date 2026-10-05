#!/usr/bin/env python3
"""(v11u245) predict_fix.py <law sweep wd> <predict_law.txt> <out>: the byte-mover predictor of the verifier's two
refinements against the LAW binary, written after the last refinement and frozen before the fix sweep.  Both live
inside § unitTdLawS245, whose set is non-empty only in the databases r11u245's predictor names (predict_law.txt, every
database with a $unit listing of a kind the laws read).  Among those, read from the LAW database:
  § unitLawSGenVarIsInstVar245v fires on a variable under a gen_scope -> trigger: a gen_scope lists vpiVariables;
  § unitLawSSkipAliasedListing245v fires on a $unit listing with its own vpiElemTypespec / vpiTypedefAlias whose
    binder the law rebound -> trigger: a design-level vpiTypedef whose vpiInstance is the design and which carries a
    vpiElemTypespec or vpiTypedefAlias.
Fenced paths are skipped unread (fail-closed on $FENCED)."""
import os, re, sys, glob, subprocess
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('predict_fix.py: source drivers/env.sh first (FENCED)')
D = os.environ.get('UHDM_DUMP', '')
if not os.access(D, os.X_OK): sys.exit('predict_fix.py: UHDM_DUMP not executable')
W, PL, OUT = sys.argv[1:4]
def fenced(p): return any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', p) for f in F)
def db(name):
    if name.startswith('probe/'): return f"{W}/probe/{name[6:].replace('/', '__')}.uhdm"
    if name.startswith('downstream/'): return f'{W}/{name}/slang.uhdm'
    c = glob.glob(f'{W}/{name}-*/slang.uhdm') + glob.glob(f'{W}/{name}/slang.uhdm')
    return c[0] if c else None
res = []
for l in open(PL):
    name = l.split('\t')[0].strip()
    if not name or fenced(name): continue
    p = db(name)
    if not p or not os.path.exists(p): res.append((name, 'NO_DB')); continue
    out = subprocess.run([D, p], capture_output=True, text=True, timeout=1800).stdout.split('\n')
    why = []
    for i, x in enumerate(out):
        if x.lstrip().startswith('\\_gen_scope:'):
            ind = len(x) - len(x.lstrip()); k = i + 1
            while k < len(out) and (len(out[k]) - len(out[k].lstrip()) > ind):
                if out[k].strip() == '|vpiVariables:' and len(out[k]) - len(out[k].lstrip()) == ind + 2:
                    why.append('genvar'); break
                k += 1
            if why: break
    i = 0
    while i < len(out):
        if out[i] == '|vpiTypedef:' and i + 1 < len(out):
            k = i + 2; inst = alias = False
            while k < len(out) and out[k].startswith('  '):
                if out[k] == '  |vpiInstance:' and k + 1 < len(out) and out[k + 1].startswith('  \\_design:'): inst = True
                if out[k] in ('  |vpiElemTypespec:', '  |vpiTypedefAlias:'): alias = True
                k += 1
            if inst and alias and out[i + 1].startswith('\\_logic_typespec'): why.append('aliasedlist ' + out[i + 1].split(',')[0][2:])
            i = k
        else: i += 1
    if why: res.append((name, ' '.join(sorted(set(why)))))
with open(OUT, 'w') as f:
    for n, w in sorted(res): f.write(f'{n}\t{w}\n')
print(f'read={sum(1 for _ in open(PL))} predicted={len(res)}')
