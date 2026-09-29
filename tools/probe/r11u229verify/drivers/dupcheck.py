#!/usr/bin/env python3
"""r11u229: dupcheck.py <dir under tools/probe>...: does any case source file of the given evidence directories repeat a
corpus source (third_party/uhdm2rtlil/test, third_party/Surelog/tests and third_party/Surelog/third_party/tests) or a
tests/probe case?  Two keys per file: the exact bytes, and the text with every `//` comment line dropped and blanks
collapsed (so a copy with a `// § law` line added still matches).  Corpus files whose path holds a fenced name are
never opened (substring match, stricter than the word boundary; fail-closed on $FENCED)."""
import os, re, sys, hashlib
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('dupcheck.py: source drivers/env.sh first')
R = os.path.realpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../../..'))
MAIN = '/home/heyfey/git-repos/slang-uhdm'
EXT = ('.sv', '.v', '.svh', '.vh')
def norm(b):
    t = b.decode('latin-1').replace('\r\n', '\n')
    t = '\n'.join(l for l in t.split('\n') if not l.strip().startswith('//'))
    return re.sub(r'\s+', ' ', t).strip()
def keys(p):
    b = open(p, 'rb').read()
    return hashlib.md5(b).hexdigest(), hashlib.md5(norm(b).encode('latin-1')).hexdigest(), len(norm(b))
ref = {}
nref = skipped = 0
for root in (f'{MAIN}/third_party/uhdm2rtlil/test', f'{MAIN}/third_party/Surelog/tests', f'{MAIN}/third_party/Surelog/third_party/tests', f'{R}/tests/probe'):
    for dp, dn, fn in os.walk(root):
        if any(f in dp for f in F): skipped += 1; dn[:] = []; continue
        for f in fn:
            p = os.path.join(dp, f)
            if not f.endswith(EXT) or any(x in p for x in F): continue
            try:
                if os.path.getsize(p) > 2_000_000: continue
                e, n, ln = keys(p)
            except OSError: continue
            nref += 1
            ref.setdefault(('e', e), p); 
            if ln > 40: ref.setdefault(('n', n), p)
print(f'# reference files hashed: {nref}; directories skipped as fenced: {skipped}')
hits = 0; ncase = 0
for d in sys.argv[1:]:
    for dp, dn, fn in os.walk(f'{R}/tools/probe/{d}'):
        for f in fn:
            if not (f.endswith(EXT) or f.endswith('.sv.txt')): continue
            p = os.path.join(dp, f); e, n, ln = keys(p); ncase += 1
            m = ref.get(('e', e)) or (ref.get(('n', n)) if ln > 40 else None)
            if m:
                hits += 1
                src = os.path.relpath(m, MAIN) if m.startswith(MAIN) else os.path.relpath(m, R)
                print(f'DUP {os.path.relpath(p, R)} == {src} ({"exact" if ref.get(("e", e)) else "comment lines aside"})')
print(f'# case files checked: {ncase}; duplicates: {hits}')
