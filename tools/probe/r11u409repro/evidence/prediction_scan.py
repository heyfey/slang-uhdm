#!/usr/bin/env python3
"""r11u409 pre-sweep prediction: a fence-filtered SOURCE scan of the two corpora
for the syntactic triggers of the six laws.  Prints, per law, the corpus test
directories whose sources hold the trigger (a superset of where the law can
fire; the sweep's R11U409_TRACE census is the exact answer)."""
import os, re, sys
ROOTS = ['/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/tests',
         '/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/tests',
         '/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test']
raw = open(sys.argv[1]).read().strip()
FENCE = [x for x in re.split(r'[ ,|()]+', raw) if x]
def fenced(p):
    return any(f in re.split(r'[/\-._]', p) for f in FENCE)
paths = []
for r in ROOTS:
    for d, ds, fs in os.walk(r):
        if fenced(d):
            ds[:] = []
            continue
        for f in fs:
            if f.endswith(('.sv', '.v', '.svh', '.vh')):
                p = os.path.join(d, f)
                if not fenced(p):
                    paths.append(p)
pats = {
  'modImpTdParamTsClone409': re.compile(r'typedef\s+(bit|int|byte)\b[^;]*?\b(\w+)\s*;'),
  'defImpArithSize32_409':   re.compile(r'^\s*(parameter|localparam)\s+[A-Za-z_]\w*\s*=\s*[^;]*[|&+\-*^][^;]*;', re.M),
  'impEnumParamRefNoSize409':re.compile(r'typedef\s+enum\s*\{'),
  'oobEventTrigHoistNet409': re.compile(r'->\s*[A-Za-z_]\w*\s*;'),
  'streamBraceParenMacro409':re.compile(r"'\(\s*\{\s*(<<|>>)"),
  'genGateTermGenvarFold409':re.compile(r'^\s*(and|or|xor|nand|nor|xnor|buf|not|bufif[01]|notif[01]|tran|rtran|tranif[01])\s+\w*\s*\(', re.M),
}
hits = {k: set() for k in pats}
for p in paths:
    try:
        t = open(p, errors='replace').read()
    except OSError:
        continue
    for k, rx in pats.items():
        if rx.search(t):
            if k == 'modImpTdParamTsClone409':
                names = {m.group(2) for m in rx.finditer(t)}
                if not any(re.search(r'(parameter|localparam)\s+' + re.escape(n) + r'\b', t) for n in names):
                    continue
            if k == 'genGateTermGenvarFold409' and 'genvar' not in t and not re.search(r'\bfor\s*\(', t):
                continue
            if k == 'streamBraceParenMacro409' and '`define' not in t:
                continue
            hits[k].add(os.path.relpath(os.path.dirname(p), '/home/heyfey/git-repos/slang-uhdm/third_party'))
for k in pats:
    print(k, len(hits[k]))
    for h in sorted(hits[k])[:400]:
        print('   ', h)
