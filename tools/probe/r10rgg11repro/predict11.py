#!/usr/bin/env python3
"""r10rgg11/predict11.py — PREDICT the mover set BY NAME from the CORPUS
SOURCES, filed BEFORE the patched sweep is read.

§ genLpPortConnValue11 can only move an object that is ALL of:
  * a localparam/parameter declared INSIDE a generate block (any declared
    type, any initializer -- unlike r10rgg10's typespec law there is NO range
    requirement here),
  * whose WHOLE actual on an instance PORT CONNECTION is the BARE NAME
    (`.formal(NAME)`) -- a select, concat, cast or call argument goes down a
    different arm and is untouched,
  * in the ELABORATED view.

The matcher is deliberately SYNTACTIC and OVER-INCLUSIVE (it cannot see which
generate branch elaborates, nor whether the name resolves to the generate-local
declaration): a name it does NOT list cannot move, which is the safe direction.
"""
import os, re, glob

HOME = os.path.expanduser('~')
SL = os.path.join(HOME, 'git-repos', 'Surelog')
U2R = os.path.join(HOME, 'git-repos', 'uhdm2rtlil', 'test')

DECL = re.compile(r'\b(?:localparam|parameter)\b[^;=\n]*?\b(\w+)\s*=')
# a port connection whose actual is EXACTLY one identifier
BARECONN = re.compile(r'^\s*\.\s*\w+\s*\(\s*([A-Za-z_]\w*)\s*\)\s*,?\s*$', re.M)
SRC = ('.sv', '.v', '.svh', '.vh')

# THE FENCE.  The four slang-fenced tests are never dispatched and are never
# spelled individually in a probe artifact; this one expression names all four
# together, which is what canaudit.sh recognises as a fence rather than a
# dispatch, and the scan SKIPS and COUNTS them (a driver that silently drops
# rows must never read as perfection).
FENCED = set('UnsignedParam|HierPathEval|FileLocalParam|TopParam'.split('|'))


def scan_file(p):
    try:
        src = open(p, 'rt', errors='replace').read()
    except OSError:
        return set()
    if 'generate' not in src and 'begin :' not in src and 'begin:' not in src:
        return set()
    names = set(m.group(1) for m in DECL.finditer(src))
    if not names:
        return set()
    return set(m.group(1) for m in BARECONN.finditer(src)) & names


def scan_dir(d):
    hits = set()
    for root, _dirs, files in os.walk(d):
        for f in files:
            if f.endswith(SRC):
                hits |= scan_file(os.path.join(root, f))
    return hits


def main():
    out = {}
    fenced = [0]
    for slf in glob.glob(os.path.join(SL, 'tests', '*', '*.sl')) + \
               glob.glob(os.path.join(SL, 'third_party', 'tests', '*', '*.sl')):
        name = os.path.basename(slf)[:-3]
        if name in FENCED:
            fenced[0] += 1
            continue
        h = scan_dir(os.path.dirname(slf))
        if h:
            out[('surelog', name)] = sorted(h)
    for d in sorted(glob.glob(os.path.join(U2R, '*'))):
        if not os.path.isdir(d):
            continue
        if os.path.basename(d) in FENCED:
            fenced[0] += 1
            continue
        h = scan_dir(d)
        if h:
            out[('uhdm2rtlil', os.path.basename(d))] = sorted(h)
    for k in sorted(out):
        print('PREDICT-SOURCE %-11s %-24s %s' % (k[0], k[1], ','.join(out[k][:12])))
    print('-- corpora scanned=2  candidate tests=%d  FENCED-SKIP=%d'
          % (len(out), fenced[0]))


main()
