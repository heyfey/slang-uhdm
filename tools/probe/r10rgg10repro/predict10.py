#!/usr/bin/env python3
"""r10rgg10/predict10.py — PREDICT the mover set BY NAME, from the CORPUS
SOURCES, BEFORE the patched sweep is read.

§ genLpPortConnRead10 can only move an object that is ALL of:
  * a localparam/parameter declared INSIDE a generate block,
  * with an explicit PACKED-VECTOR type (`bit [..]` / `logic [..]` / a ranged
    keyword) -- a scalar `bit`, an `int` and an untyped param have no range and
    `CompileHelper::setRange`'s `if (lr || rr)` refuses them,
  * READ by an INSTANCE PORT CONNECTION in that same generate block (a bare
    name, or a select of it),
  * and NOT already rewritten by the cont-assign read gate this pass extends.

The matcher below is deliberately SYNTACTIC and OVER-INCLUSIVE (it cannot see
which branch elaborates, and it counts a cont-assign read as well so the
already-bare cases are visible): a name it does NOT list cannot move, which is
the direction a prediction has to be safe in.
"""
import os, re, sys, glob

HOME = os.path.expanduser('~')
SL = os.path.join(HOME, 'git-repos', 'Surelog')
U2R = os.path.join(HOME, 'git-repos', 'uhdm2rtlil', 'test')

DECL = re.compile(r'\b(localparam|parameter)\s+(?:bit|logic|reg|wire)?\s*(?:signed\s*)?\[[^\]]+\]\s*(\w+)\s*=')
GENOPEN = re.compile(r'^\s*(if|for|case)\s*\(|^\s*begin\b|\bgenerate\b')
PORTCONN = re.compile(r'^\s*\.\s*\w+\s*\(([^)]*)\)', re.M)


def scan_file(p):
    """-> set of localparam names declared in a generate block AND named in a
    port connection actual somewhere in the same file."""
    try:
        src = open(p, 'rt', errors='replace').read()
    except OSError:
        return set()
    if 'generate' not in src and 'begin :' not in src and 'begin:' not in src:
        return set()
    names = set()
    for m in DECL.finditer(src):
        names.add(m.group(2))
    if not names:
        return set()
    hit = set()
    for m in PORTCONN.finditer(src):
        act = m.group(1)
        for n in names:
            if re.search(r'\b%s\b' % re.escape(n), act):
                hit.add(n)
    return hit


def corpus_surelog():
    out = {}
    for slf in glob.glob(os.path.join(SL, 'tests', '*', '*.sl')) + \
               glob.glob(os.path.join(SL, 'third_party', 'tests', '*', '*.sl')):
        d = os.path.dirname(slf)
        name = os.path.basename(slf)[:-3]
        hits = set()
        for root, _dirs, files in os.walk(d):
            for f in files:
                if f.endswith(('.sv', '.v', '.svh', '.vh')):
                    hits |= scan_file(os.path.join(root, f))
        if hits:
            out[name] = sorted(hits)
    return out


def corpus_u2r():
    out = {}
    for d in sorted(glob.glob(os.path.join(U2R, '*'))):
        if not os.path.isdir(d):
            continue
        hits = set()
        for root, _dirs, files in os.walk(d):
            for f in files:
                if f.endswith(('.sv', '.v', '.svh', '.vh')):
                    hits |= scan_file(os.path.join(root, f))
        if hits:
            out[os.path.basename(d)] = sorted(hits)
    return out


which = sys.argv[1] if len(sys.argv) > 1 else 'both'
if which in ('both', 'surelog'):
    r = corpus_surelog()
    print('== surelog corpus CANDIDATES: %d tests ==' % len(r))
    for k in sorted(r):
        print('  %-32s %s' % (k, ','.join(r[k][:8])))
if which in ('both', 'uhdm2rtlil'):
    r = corpus_u2r()
    print('== uhdm2rtlil corpus CANDIDATES: %d tests ==' % len(r))
    for k in sorted(r):
        print('  %-32s %s' % (k, ','.join(r[k][:8])))
