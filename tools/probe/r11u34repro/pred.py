#!/usr/bin/env python3
"""r11u34 PREDICTOR / SHAPE LISTER.

Walks a verify_golden workdir, dumps each side's database once, and reports for
every test whether its ELABORATED PACKAGE listing (|uhdmtopPackages:) holds a
NESTED assignment-pattern operation carrying a vpiSize -- the cell
§ pkgNestedPatElabNoExpandSize34 removes.  Prints one line per test per side so
the census can be read golden-vs-golden FIRST (the positive control is that the
golden column is NON-EMPTY: golden does stamp this cell, for the scoped-`pkg::`
face).

usage: pred.py <workdir> <mode> [--side g|o|both]
"""
import os, re, subprocess, sys

DUMP = '/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump'

def nested_sized(dump_text):
    """[(loc, size)] for every op75/op76 that is INSIDE another op75/op76 in the
    uhdmtopPackages section and carries a vpiSize."""
    out = []
    sect = None
    stack = []          # (indent, is_pattern_op)
    lines = dump_text.splitlines()
    for i, ln in enumerate(lines):
        m = re.match(r'^\|(uhdm\w+):', ln)
        if m:
            sect = m.group(1); stack = []; continue
        if sect != 'uhdmtopPackages':
            continue
        m = re.match(r'^(\s*)\\_operation: , (line:[\d:]+, endln:[\d:]+)', ln)
        if not m:
            continue
        ind = len(m.group(1)); loc = m.group(2)
        size = None; optype = None
        j = i + 1
        while j < len(lines):
            l2 = lines[j]
            k = len(l2) - len(l2.lstrip())
            if k <= ind:
                break
            if k == ind + 2 and l2.lstrip().startswith('|vpiSize:'):
                size = l2.split(':')[-1]
            if k == ind + 2 and l2.lstrip().startswith('|vpiOpType:'):
                optype = l2.split(':')[-1]
            j += 1
        while stack and stack[-1][0] >= ind:
            stack.pop()
        inpat = any(p for _, p in stack)
        ispat = optype in ('75', '76')
        if ispat and inpat and size is not None:
            out.append((loc, size))
        stack.append((ind, ispat))
    return out

def main():
    wd, mode = sys.argv[1], sys.argv[2]
    root = os.path.join(wd, mode)
    for d in sorted(os.listdir(root)):
        p = os.path.join(root, d)
        if not os.path.isdir(p):
            continue
        name = d.rsplit('-', 1)[0]
        cmds = os.path.join(p, 'cmds.txt')
        g = None
        if os.path.exists(cmds):
            t = open(cmds).read()
            m = re.search(r'golden cache hit (/\S+?)\)', t)
            if m:
                g = os.path.join(m.group(1), 'golden.uhdm')
            else:
                m = re.search(r'-o (\S+)\s*$', t.splitlines()[0])
        o = os.path.join(p, 'slang.uhdm')
        for tag, path in (('G', g), ('O', o)):
            if not path or not os.path.exists(path):
                continue
            try:
                r = subprocess.run([DUMP, path], capture_output=True, text=True,
                                   timeout=600)
            except subprocess.TimeoutExpired:
                print('%s %s %s TIMEOUT' % (name, mode, tag)); continue
            if r.returncode:
                print('%s %s %s DUMPFAIL' % (name, mode, tag)); continue
            hits = nested_sized(r.stdout)
            if hits:
                print('%s %s %s %d %s' % (name, mode, tag, len(hits),
                                          ';'.join('%s=%s' % h for h in hits)))

main()
