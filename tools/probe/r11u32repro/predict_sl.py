#!/usr/bin/env python3
"""r11u32 — A-PRIORI mover prediction over the SURELOG corpus, from the sources
the harness itself hands each test (one test per *.sl, the test dir).  Same two
source shapes as the u2r predictor, same deliberate over-prediction.

FENCE: the four slang-fenced names are never spelled here; the list is read
from a file the caller builds, and a fenced test is simply dropped from the
OUTPUT (it is not dispatched by this script — nothing is run).
"""
import os, re, sys

TYPEPARAM = re.compile(r'\bparameter\s+type\s+(\w+)')
ENUMTD    = re.compile(r'\btypedef\s+enum\b[^;]*?\b(\w+)\s*;', re.S)
DIMUSE    = re.compile(r'(?<![\w.])(\w+)\s*\[[^\];]*\]\s+\w+\s*(?:;|,|\)|\[)')
SRC_EXT   = ('.sv', '.v', '.svh', '.vh')

def scan_dir(d, budget=4000):
    names, uses, n = set(), set(), 0
    for root, _dirs, files in os.walk(d):
        for f in files:
            if not f.endswith(SRC_EXT):
                continue
            n += 1
            if n > budget:
                return names & uses
            try:
                txt = open(os.path.join(root, f), errors='replace').read()
            except OSError:
                continue
            for m in TYPEPARAM.finditer(txt):
                names.add(m.group(1))
            for m in ENUMTD.finditer(txt):
                names.add(m.group(1))
            for m in DIMUSE.finditer(txt):
                uses.add(m.group(1))
    return names & uses

def main():
    root = os.path.expanduser('~/git-repos/Surelog')
    fenced = set()
    if len(sys.argv) > 1 and os.path.isfile(sys.argv[1]):
        fenced = {l.strip() for l in open(sys.argv[1]) if l.strip()}
    tests = {}
    for r in (os.path.join(root, 'tests'), os.path.join(root, 'third_party', 'tests')):
        for dirpath, _d, files in os.walk(r):
            for fn in files:
                if fn.endswith('.sl'):
                    tests[fn[:-3]] = dirpath
    hits = {}
    for name, d in sorted(tests.items()):
        if name in fenced:
            continue
        h = scan_dir(d)
        if h:
            hits[name] = sorted(h)
    for k, v in sorted(hits.items()):
        print(f'{k}\t{",".join(v[:12])}{" ..." if len(v) > 12 else ""}')
    print(f'-- TESTS: {len(tests)}   PREDICTED CANDIDATES: {len(hits)}')

main()
