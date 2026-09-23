#!/usr/bin/env python3
"""r11u107 SOURCE census (prediction aid; measurement only).

For every test of both corpora (discovered exactly as scripts/verify_golden.py
discovers them) scan the listed source files (+ `-f` command files, one
level) for the three written shapes the pass's laws key on:
  A  anonymous PACKED struct/union (not `signed`) followed by a packed dim
  B  `type X = struct|union packed ...` (a type-parameter default)
  C  `type X = NAME [..]` (a named element with a packed dim; § 31 shape)
Prints `<corpus> <test> A=n B=n C=n` for rows with any hit.
"""
import os, re, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', 'scripts'))
import verify_golden as vg
FENCED = set(os.environ.get('FENCED', '').split(',')) - {''}
def strip_comments(t):
    t = re.sub(r'/\*.*?\*/', ' ', t, flags=re.S)
    return re.sub(r'//[^\n]*', ' ', t)
AGG = re.compile(r'\b(struct|union)\s+packed\b(\s+(signed|unsigned))?\s*\{')
TPB = re.compile(r'\btype\s+\w+\s*=\s*(struct|union)\s+packed\b')
TPC = re.compile(r'\btype\s+\w+\s*=\s*([A-Za-z_]\w*)\s*\[')
def count(text):
    a = 0
    for m in AGG.finditer(text):
        if m.group(3) == 'signed':
            continue
        i = m.end(); depth = 1
        while i < len(text) and depth:
            if text[i] == '{': depth += 1
            elif text[i] == '}': depth -= 1
            i += 1
        j = i
        while j < len(text) and text[j].isspace(): j += 1
        if j < len(text) and text[j] == '[':
            a += 1
    return a, len(TPB.findall(text)), len(TPC.findall(text))
def files_of(dirpath, parts):
    srcs, opts = vg.split_sources(parts)
    out = []
    for k, o in enumerate(opts):
        if o == '-f' and k + 1 < len(opts):
            fp = os.path.join(dirpath, opts[k + 1])
            if os.path.isfile(fp):
                for ln in open(fp, errors='replace'):
                    ln = ln.strip()
                    if ln and not ln.startswith(('-', '+', '#', '//')):
                        out.append(os.path.join(os.path.dirname(fp), ln))
    for s in srcs:
        out.append(os.path.join(dirpath, s))
    return [f for f in out if os.path.isfile(f)]
for corpus, disc in (('surelog', vg.discover_surelog), ('uhdm2rtlil', vg.discover_uhdm2rtlil)):
    for name, (dirpath, parts) in disc(None).items():
        if name in FENCED:
            continue
        A = B = C = 0
        for f in files_of(dirpath, parts):
            try:
                t = strip_comments(open(f, errors='replace').read())
            except OSError:
                continue
            a, b, c = count(t); A += a; B += b; C += c
        if A or B or C:
            print(f'{corpus} {name} A={A} B={B} C={C}')
