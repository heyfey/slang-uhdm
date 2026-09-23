#!/usr/bin/env python3
"""predict117.py — SOURCE-side candidate lister for the r11u117 laws, per test
row of both corpora (discovery exactly as scripts/verify_golden.py).
  QSEL : a package-qualified member select `pkg::NAME.member` written inside a
         parameter/localparam declaration (the § pkgQualSelParamFlat117 trigger).
  DBL  : a typedef of a packed array whose element is a USER type
         (`typedef ut_e [0:2] row_t`) — the § pkgFlatSurelogBits117 shape.
A row is listed when any of its source files (the test dir's .sv/.v/.svh/.vh
files, recursively) carries the shape.  This is the a-priori candidate set;
the pristine databases then decide which candidates can move (the lister
beside it), and byteverify is the arbiter."""
import os, re, sys
sys.path.insert(0, '/home/heyfey/git-repos/slang-uhdm/scripts')
import verify_golden as vg
KW = set('logic bit reg int integer byte shortint longint time real wire signed unsigned string'.split())
qsel = re.compile(r'\b(localparam|parameter)\b[^;]*?\b([A-Za-z_]\w*)::([A-Za-z_]\w*)\s*\.\s*[A-Za-z_]', re.S)
dbl = re.compile(r'\btypedef\s+(?:[A-Za-z_]\w*::)?([A-Za-z_]\w*)\s*\[')
cache = {}
def scan(path):
    if path in cache: return cache[path]
    try: t = open(path, errors='replace').read()
    except Exception: cache[path] = (set(), set()); return cache[path]
    t = re.sub(r'//[^\n]*', '', t); t = re.sub(r'/\*.*?\*/', '', t, flags=re.S)
    q = set('%s::%s' % (m.group(2), m.group(3)) for m in qsel.finditer(t))
    d = set(m.group(1) for m in dbl.finditer(t) if m.group(1) not in KW)
    cache[path] = (q, d); return cache[path]
def files(dirpath):
    out = []
    for r, _d, fs in os.walk(dirpath):
        for f in fs:
            if f.endswith(('.sv', '.v', '.svh', '.vh', '.pkg')): out.append(os.path.join(r, f))
    return out
for corpus, disc in (('surelog', vg.discover_surelog), ('uhdm2rtlil', vg.discover_uhdm2rtlil)):
    for name, (dirpath, _args) in disc(None).items():
        Q, Dd = set(), set()
        for f in files(dirpath):
            q, d = scan(f); Q |= q; Dd |= d
        if Q or Dd:
            print('%s %s QSEL=%s DBL=%s' % (corpus, name, ','.join(sorted(Q)) or '-', ','.join(sorted(Dd))[:200] or '-'))
