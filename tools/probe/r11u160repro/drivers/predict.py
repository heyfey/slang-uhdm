#!/usr/bin/env python3
"""predict.py: the source-shape census of r11u160's laws over both corpora
(fail-closed on $FENCED: refuses to run without the four slang-fenced names and
never opens a fenced test's directory).  Prints, per law, the tests whose
sources show the law's shape.  Sources = the files under the test's own
directory (the uhdm2rtlil ibex tests also read test/ibex/**)."""
import os, re, sys
F = os.environ.get('FENCED', '').split()
if len(F) != 4:
    sys.exit('predict.py: export FENCED (four names) first')
SL = os.environ['SURELOG_ROOT']; U2 = os.environ['UHDM2RTLIL_TESTS']
tests = {}
for base in (os.path.join(SL, 'tests'), os.path.join(SL, 'third_party', 'tests')):
    for n in sorted(os.listdir(base)):
        d = os.path.join(base, n)
        if os.path.isdir(d) and not any(re.fullmatch(re.escape(f), n) for f in F):
            tests.setdefault(('surelog', n), []).append(d)
for n in sorted(os.listdir(U2)):
    d = os.path.join(U2, n)
    if os.path.isdir(d) and not any(re.fullmatch(re.escape(f), n) for f in F):
        tests[('uhdm2rtlil', n)] = [d] + ([os.path.join(U2, 'ibex')] if n.startswith('ibex_') else [])
EXT = ('.sv', '.v', '.svh', '.vh', '.inc', '.svi')
def text(ds):
    out = []
    for d in ds:
        for dp, _, fs in os.walk(d):
            for f in fs:
                if f.endswith(EXT):
                    try:
                        out.append(open(os.path.join(dp, f), errors='replace').read())
                    except OSError:
                        pass
    return '\n'.join(out)
R = {
 'objMacroParenArgsTrimmed160': lambda t: any(re.search(r'`' + re.escape(m) + r'[ \t]+\(', t)
     for m in re.findall(r'^\s*`define\s+(\w+)[ \t]+[^(\n\\][^\n]*$', t, re.M)),
 'ppMacroBodyLines160(inactive)': lambda t: any(re.match(r'\s*`if(n)?def', ln) and prev.rstrip().endswith('\\') for prev, ln in zip(t.split('\n'), t.split('\n')[1:])),
 'ppMacroBodyLines160(builtin)': lambda t: re.search(r'`__(FILE|LINE)__', t) is not None,
 'ppMacroBodyLines160(paste)': lambda t: '``' in t,
 'ppMacroBodyLines160(stringify)': lambda t: re.search(r'`define\s+\w+\([^)]*\)\s*`"', t) is not None,
 'ppMacroBodyLines160(argnl)': lambda t: re.search(r'^\s*`\w+\([^()\n]*$', t, re.M) is not None,
 'type-parameter laws (TPWHOLELHS TPPACKEDVEC BODYTPDEF TPUSEDEF TPUSEUNIT)': lambda t: re.search(r'\b(parameter|localparam)\s+type\b', t) is not None,
 'implNetBareParamElab160': lambda t: re.search(r'\bassign\s+(\w+)\s*=\s*(\w+)\s*;', t) is not None and re.search(r'\bparameter\b', t) is not None,
 'uncaughtExitsReject160': lambda t: re.search(r'\\[!-~]*#[!-~]* ', t) is not None,
}
hits = {k: [] for k in R}
for (c, n), ds in sorted(tests.items()):
    t = text(ds)
    for k, f in R.items():
        if f(t):
            hits[k].append(f'{c}/{n}')
for k, v in hits.items():
    print(f'== {k}: {len(v)} tests')
    print('  ' + ' '.join(v))
