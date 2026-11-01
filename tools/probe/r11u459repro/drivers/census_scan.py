#!/usr/bin/env python3
"""census_scan.py <fence-file> <out-dir>: text census of the rows this pass's
three laws can fire on, per corpus (surelog, uhdm2rtlil, probe, svtests).
Every path list is filtered on the fence names BEFORE any file is opened.
  A  § defFlipUnszBasedRaw459: a typed parameter with an unsized based literal
     default + a module/interface with a parameter port list + an import
  B  § unitImpTransLateList459: a foreach + a file-scope (column 0) import
     + a package whose body imports another package
  C  § pkgBitsTypeEnumZero459: $bits in a parameter declaration + a base-less enum
Writes <out-dir>/<corpus>.cand (one row name per line, with the laws)."""
import os, re, sys, glob
REPO = '/home/heyfey/git-repos/slang-uhdm'
sys.path.insert(0, os.path.join(REPO, 'scripts'))
fence = [l.strip() for l in open(sys.argv[1]) if l.strip()]
out = sys.argv[2]
os.makedirs(out, exist_ok=True)
def fenced(p):
    return any(f in p for f in fence)
A1 = re.compile(r"\b(parameter|localparam)\s+[A-Za-z_][\w:]*(\s+(signed|unsigned))?(\s*\[[^\]]*\])*\s+[A-Za-z_]\w*\s*=\s*'[sS]?[bBoOhH]")
A2 = re.compile(r"\b(module|interface)\s+(automatic\s+|static\s+)?\w+\s*(import\s[^;]*;\s*)*#\s*\(")
A3 = re.compile(r"\bimport\s+\w+::")
B1 = re.compile(r"\bforeach\b")
B2 = re.compile(r"^import\s+\w+::", re.M)
B3 = re.compile(r"\bpackage\s+\w+\s*;(?:(?!\bendpackage\b)[\s\S])*?\bimport\s+\w+::")
C1 = re.compile(r"\b(parameter|localparam)\b[^;]*\$bits\s*\(")
C2 = re.compile(r"\benum\s*\{")
cache = {}
def flags(p):
    if p in cache:
        return cache[p]
    try:
        t = open(p, errors='replace').read()
    except Exception:
        t = ''
    f = set()
    if A1.search(t): f.add('A1')
    if A2.search(t): f.add('A2')
    if A3.search(t): f.add('A3')
    if B1.search(t): f.add('B1')
    if B2.search(t): f.add('B2')
    if B3.search(t): f.add('B3')
    if C1.search(t): f.add('C1')
    if C2.search(t): f.add('C2')
    cache[p] = f
    return f
def srcs_in(d, rec=False):
    pats = ('*.sv', '*.svh', '*.v', '*.vh', '*.pkg', '*.inc')
    r = []
    for pt in pats:
        r += glob.glob(os.path.join(d, '**', pt) if rec else os.path.join(d, pt), recursive=rec)
    return r
UVMSRC = os.path.join(REPO, 'third_party/Surelog/third_party/UVM')
def judge(files):
    files = [f for f in files if not fenced(f)]
    F = set()
    for f in files:
        g = flags(f)
        # a file-scope import inside the bundled UVM library is not the
        # row's own $unit import (the library imports nothing at file scope
        # that a row compiles into $unit except through its own files)
        if UVMSRC in os.path.abspath(f):
            g = g - {'B2'}
        F |= g
    laws = []
    if {'A1', 'A2', 'A3'} <= F: laws.append('A')
    if {'B1', 'B2', 'B3'} <= F: laws.append('B')
    if {'C1', 'C2'} <= F: laws.append('C')
    return laws
def write(corpus, rows):
    with open(os.path.join(out, corpus + '.cand'), 'w') as fo:
        for name, laws in rows:
            if laws:
                fo.write(name + ' ' + ''.join(laws) + '\n')
    print(corpus, len(rows), 'rows,', sum(1 for _, l in rows if l), 'candidates')
# surelog corpus
import verify_golden as vg
rows = []
for name, (d, args) in vg.discover_surelog(None).items():
    if fenced(name) or fenced(d):
        continue
    files = []
    for a in args:
        for pre in ('-I', '+incdir+'):
            if a.startswith(pre) and len(a) > len(pre):
                inc = a[len(pre):]
                inc = inc if os.path.isabs(inc) else os.path.join(d, inc)
                if os.path.isdir(inc) and not fenced(inc):
                    files += srcs_in(inc)
        p = a if os.path.isabs(a) else os.path.join(d, a)
        if os.path.isfile(p):
            files.append(p)
    if any('UVM' in a or 'uvm' in a.lower() for a in args):
        files += [f for f in srcs_in(UVMSRC, True)]
    files += srcs_in(d)
    rows.append((name, judge(files)))
write('surelog', rows)
# uhdm2rtlil
rows = []
for name, (d, args) in vg.discover_uhdm2rtlil(None).items():
    if fenced(name) or fenced(d):
        continue
    rows.append((name, judge(srcs_in(d, True))))
write('uhdm2rtlil', rows)
# probe
rows = []
pr = os.path.join(REPO, 'tests/probe')
for dut in sorted(glob.glob(os.path.join(pr, '**', 'dut.sv'), recursive=True)):
    if fenced(dut):
        continue
    d = os.path.dirname(dut)
    rows.append((os.path.relpath(d, pr), judge(srcs_in(d))))
write('probe', rows)
# sv-tests (the rows of results/golden_svtests.csv)
SV = '/home/heyfey/git-repos/sv-tests'
import csv
rows = []
uvm17 = os.path.join(REPO, 'third_party/Surelog/third_party/UVM/1800.2-2017-1.0/src')
for r in csv.DictReader(open(os.path.join(REPO, 'results/golden_svtests.csv'))):
    rel = r['case']
    if fenced(rel):
        continue
    p = os.path.join(SV, 'tests', rel)
    files = [p]
    try:
        head = open(p, errors='replace').read(4000)
    except Exception:
        head = ''
    m = re.search(r'^:files:\s*(.+)$', head, re.M)
    if m:
        files += [f if os.path.isabs(f) else os.path.join(SV, f) for f in m.group(1).split()]
    m = re.search(r'^:incdirs:\s*(.+)$', head, re.M)
    if m:
        for inc in m.group(1).split():
            inc = inc if os.path.isabs(inc) else os.path.join(SV, inc)
            if os.path.isdir(inc):
                files += srcs_in(inc)
    m = re.search(r'^:tags:\s*(.+)$', head, re.M)
    if m and 'uvm' in m.group(1).split():
        files += srcs_in(uvm17, True)
    rows.append((rel, judge(files)))
write('svtests', rows)
