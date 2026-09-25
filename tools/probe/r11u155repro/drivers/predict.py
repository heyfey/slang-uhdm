#!/usr/bin/env python3
"""predict.py <out.txt>: the pass-155 mover PREDICTION by source shape, run on the pristine corpora
BEFORE the law sweep.  For every law a (deliberately wide) regex census over each corpus test's
sources names the tests whose databases the law can move; the byte verifier's movers must be a
subset of the union.  Fail-closed on $FENCED (the four slang-fenced test names, word match): the
script refuses to run without it and never opens a fenced test's directory."""
import os, re, sys, glob

FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4:
    sys.exit('predict.py: export FENCED (four names) first')
SL = os.environ.get('SURELOG_ROOT', '/home/heyfey/git-repos/slang-uhdm/third_party/Surelog')
U2R = os.environ.get('UHDM2RTLIL_TESTS', '/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test')

def fenced(name):
    return any(re.search(r'\b%s\b' % re.escape(f), name) for f in FENCED)

def tests():
    for base in (os.path.join(SL, 'tests'), os.path.join(SL, 'third_party', 'tests')):
        for d in sorted(glob.glob(os.path.join(base, '*'))):
            if os.path.isdir(d) and glob.glob(os.path.join(d, '*.sl')):
                yield 'surelog', os.path.basename(d), d
    for d in sorted(glob.glob(os.path.join(U2R, '*'))):
        if os.path.isdir(d):
            yield 'uhdm2rtlil', os.path.basename(d), d

def text_of(d):
    out = []
    for root, _, files in os.walk(d):
        for f in files:
            if f.endswith(('.sv', '.v', '.svh', '.vh', '.inc', '.svi')):
                try:
                    with open(os.path.join(root, f), errors='replace') as fh:
                        out.append(fh.read())
                except OSError:
                    pass
    t = '\n'.join(out)
    t = re.sub(r'//[^\n]*', '', t)
    return re.sub(r'/\*.*?\*/', '', t, flags=re.S)

TYPES = r'(?:integer|int|byte|shortint|longint|logic|bit|reg|string|real|time)'
LAWS = {
    # § initTsEndProgramLocal155: a program with an initialised process local
    'initTsEndProgramLocal155': lambda t: re.search(r'\bprogram\b', t) and re.search(
        r'\b(initial|always|final)\b', t) and re.search(r'\bbegin\b[^;]*?\b\w+\s+\w+\s*=', t),
    # § implicitArgDimsInner155: a subroutine formal written as bare packed dims
    'implicitArgDimsInner155': lambda t: re.search(
        r'\b(function|task)\b[^;]*?[(,]\s*\[[^\]]*\]', t),
    # § nonAnsiArrayNetAtHeader155: a port declaration with an unpacked dimension
    'nonAnsiArrayNetAtHeader155': lambda t: re.search(
        r'^\s*(input|output|inout)\b[^;()]*\b\w+\s*\[[^\]]*\]\s*[;,]', t, re.M),
    # § unitAggTfArgLastWriter155 / § modAggTfArgLastWriter155: a struct/union typedef named by a formal
    'aggTfArgLastWriter155': lambda t: any(
        re.search(r'\b(function|task)\b[^;]*?[(,]\s*(input\s+|output\s+|inout\s+|ref\s+)?%s\b' % re.escape(n), t)
        for n in set(re.findall(r'typedef\s+(?:struct|union)\b[^{]*\{.*?\}\s*(\w+)\s*;', t, re.S))),
    # § pselConnNameNotFrozen155: a part-select port actual
    'pselConnNameNotFrozen155': lambda t: re.search(r'\.\w+\s*\(\s*[\w.]+\s*\[[^\]]*[:][^\]]*\]\s*\)', t) or
        re.search(r'\(\s*[^;]*\w+\s*\[[^\]]*:[^\]]*\]\s*[,)]', t) and re.search(r'\bgenerate\b|\bgenvar\b|\bif\s*\(', t),
    # § packedStructNdaFoldConstLoc155: a declaration with a one-element assignment pattern
    'packedStructNdaFoldConstLoc155': lambda t: re.search(r"\b\w+\s+\w+\s*=\s*'\{[^,{}]*\}\s*;", t),
    # § ifacePortViewFoldAtLeftOperand155: an interface localparam with an operator
    'ifacePortViewFoldAtLeftOperand155': lambda t: re.search(r'\binterface\b', t) and re.search(
        r'\b(localparam|parameter)\b[^;]*=[^;]*[-+*/%<>&|^~!?]', t),
    # § pkgTdStretchNonAnsiHeaderSkips155: import + a non-ANSI or empty port list
    'pkgTdStretchNonAnsiHeaderSkips155': lambda t: re.search(r'\bimport\b', t) and (
        re.search(r'\bmodule\s+\w+\s*(#\s*\([^;]*?\))?\s*\(\s*\)', t, re.S) or
        re.search(r'\bmodule\s+\w+\s*(#\s*\([^;]*?\))?\s*\(\s*\w+\s*[,)]', t, re.S)),
    # § dirlessFormalTypeAtName155: a formal written as a named type with packed dims, no direction
    'dirlessFormalTypeAtName155': lambda t: re.search(
        r'\b(function|task)\b[^;]*?[(,]\s*(\w+::)?\w+\s*\[[^\]]*\]\s*\w+', t),
    # § ifaceSigConnNamedByChildPort155: an interface-member actual on a child port
    'ifaceSigConnNamedByChildPort155': lambda t: re.search(r'\bmodport\b', t) and (
        re.search(r'\.\w+\s*\(\s*\w+\.\w+\s*\)', t) or re.search(r'\w+\s+\w+\s*\(\s*\w+\.\w+\s*,', t)),
}

res = {k: [] for k in LAWS}
n = 0
for corpus, name, d in tests():
    if fenced(name):
        continue
    n += 1
    t = text_of(d)
    for k, f in LAWS.items():
        if f(t):
            res[k].append('%s/%s' % (corpus, name))
with open(sys.argv[1], 'w') as out:
    out.write('# tests scanned: %d (fenced skipped)\n' % n)
    allp = set()
    for k, v in res.items():
        out.write('%s %d %s\n' % (k, len(v), ' '.join(v)))
        allp.update(v)
    out.write('UNION %d %s\n' % (len(allp), ' '.join(sorted(allp))))
print('scanned', n, 'union', len(allp))
