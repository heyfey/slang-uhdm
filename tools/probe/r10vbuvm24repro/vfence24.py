#!/usr/bin/env python3
"""r10vbuvm24repro/vfence24.py — THE VERIFIER'S OWN FENCE: which sweep cells
CAN move, enumerated from the SOURCES, before any patched database exists.

    vfence24.py <sweep workdir root>   # e.g. /tmp/vbuvm24_wd/pris/sl

For every cell that produced a `slang.uhdm` (only those can move), the cell's
source files are recovered by matching the cell directory's sha1 suffix
against every directory under the two corpus roots (verify_golden.py names a
cell `<test>-<sha1(dirpath)[:8]>`), and each source is scanned LEXICALLY for a
written-but-empty slot:  `,` followed by `,` or `)`, or `(` followed by `,`.

Comments are stripped and string literals are replaced by a TOKEN rather than
deleted -- deleting them turns `$display("%d", x)` into `(, x)` and floods the
scan.  The result is a genuine SUPERSET of the call-argument population (it
also catches port lists, foreach index lists and sequence instances), which is
the point: a fence has to be enumerable, not guessed.
"""
import os, re, sys, hashlib

HOME = os.path.expanduser('~')
ROOTS = [os.path.join(HOME, 'git-repos', 'Surelog'),
         os.path.join(HOME, 'git-repos', 'uhdm2rtlil', 'test'),
         os.path.join(HOME, 'git-repos', 'sv-tests')]

def dirmap():
    m = {}
    for r in ROOTS:
        for dp, dns, fns in os.walk(r):
            m.setdefault(hashlib.sha1(dp.encode()).hexdigest()[:8], dp)
    return m

BLOCK = re.compile(r'/\*.*?\*/', re.S)
LINE = re.compile(r'//[^\n]*')
STR = re.compile(r'"(\\.|[^"\\])*"')

def strip(t):
    t = BLOCK.sub(' ', t)
    t = LINE.sub(' ', t)
    t = STR.sub('S', t)
    return t

EMPTY = re.compile(r',\s*(?=[,)])|\(\s*(?=,)')

def scan(path):
    try:
        t = open(path, encoding='utf-8', errors='replace').read()
    except OSError:
        return 0
    return len(EMPTY.findall(strip(t)))

def main():
    W = sys.argv[1]
    dm = dirmap()
    cells = []
    for mode in sorted(os.listdir(W)):
        md = os.path.join(W, mode)
        if not os.path.isdir(md):
            continue
        for cell in sorted(os.listdir(md)):
            cd = os.path.join(md, cell)
            if not os.path.isfile(os.path.join(cd, 'slang.uhdm')):
                continue
            cells.append((mode, cell, cd))
    print('CELLS WITH A DATABASE: %d' % len(cells))
    unres = 0
    hits = []
    for mode, cell, cd in cells:
        h = cell.rsplit('-', 1)[-1]
        dp = dm.get(h)
        if not dp:
            unres += 1
            continue
        srcs, incs = [], []
        try:
            toks = []
            for ln in open(os.path.join(cd, 'cmds.txt')):
                if ln.startswith('slang:'):
                    toks = ln.split()[1:]
            i = 0
            while i < len(toks):
                t = toks[i]
                if t.endswith(('.sv', '.v', '.svh')):
                    srcs.append(t)
                elif t.startswith('+incdir+'):
                    incs += t[len('+incdir+'):].split('+')
                elif t in ('-I', '-y', '--include-directory'):
                    i += 1
                    if i < len(toks):
                        incs.append(toks[i])
                elif t.startswith('-I'):
                    incs.append(t[2:])
                i += 1
        except OSError:
            pass
        # every listed source, plus EVERY .sv/.svh/.v reachable from an include
        # directory: an `include`d library file (uvm_pkg.sv) is where the corpus
        # keeps its empty slots, and a command-line-only scan misses it.
        files = set()
        for s in srcs:
            files.add(s if os.path.isabs(s) else os.path.join(dp, s))
        for d in incs:
            d = d if os.path.isabs(d) else os.path.join(dp, d)
            for ddp, _dn, fns in os.walk(d):
                for f in fns:
                    if f.endswith(('.sv', '.svh', '.v')):
                        files.add(os.path.join(ddp, f))
        n = 0
        for f in sorted(files):
            n += scan(f)
        if n:
            hits.append((mode, cell.rsplit('-', 1)[0], n))
    print('UNRESOLVED SOURCE DIRS: %d' % unres)
    print('CELLS WITH A LEXICAL EMPTY SLOT: %d' % len(hits))
    for m, n, c in sorted(hits):
        print('  FENCE %s/%s slots=%d' % (m, n, c))

main()
