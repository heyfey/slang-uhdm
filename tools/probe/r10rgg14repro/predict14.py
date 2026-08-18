#!/usr/bin/env python3
"""r10rgg14/predict14.py — PREDICT the mover set BY NAME from the PRISTINE
databases, BEFORE byteverify runs.

  usage: predict14.py <base-workdir> <outfile>

§ genvarIdxFoldRerender14 rewrites exactly ONE object shape: the CONSTANT that
is the vpiIndex of a bit_select sitting in a port's vpiHighConn, when that index
reads a GENVAR.  In a PRISTINE base database that object shows up two ways:

  (A) the interface-instance-array arm left the SOURCE TEXT in the decompile, so
      the decompile is not a plain non-negative decimal   -> CERTAIN mover;
  (B) the net-array `genvarConnFold` arm already folded the VALUE, so the base
      decompile is a decimal and the base dump cannot show the operator.  Those
      move only when a MULT / DIV / SUB is on the spine -- and the GOLDEN
      database shows exactly that, stamping vpiConstType 7 where ours stamps 9.
      Both sides are pristine, so this is still a prediction and not a
      measurement of the patch.

A database with neither shape cannot move.  This script never enumerates test
NAMES of its own -- it walks the workdir the sweep already built -- so the
slang-fenced tests are structurally out of reach.
"""
import os, re, subprocess, sys

DUMP = os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump')

def hcidx(path):
    """(decompile, consttype, size) of every HighConn bit_select index constant."""
    try:
        txt = subprocess.run([DUMP, path], capture_output=True, text=True,
                             timeout=1200).stdout
    except Exception:
        return None
    lines = txt.split('\n')
    ind = [len(l) - len(l.lstrip()) for l in lines]
    out = []
    for n, l in enumerate(lines):
        if l.strip() != '|vpiHighConn:':
            continue
        if n + 1 >= len(lines) or '\\_bit_select:' not in lines[n + 1]:
            continue
        base = ind[n + 1]
        k = n + 2
        while k < len(lines) and (ind[k] > base or not lines[k].strip()):
            if lines[k].strip() == '|vpiIndex:' and k + 1 < len(lines) and \
               '\\_constant:' in lines[k + 1]:
                cb = ind[k + 1]
                d = k + 2
                dec = ct = sz = None
                while d < len(lines) and ind[d] > cb:
                    s = lines[d].strip()
                    if s.startswith('|vpiDecompile:'):  dec = s[14:]
                    elif s.startswith('|vpiConstType:'): ct = s[14:]
                    elif s.startswith('|vpiSize:'):      sz = s[9:]
                    d += 1
                out.append((dec, ct, sz))
            k += 1
    return out

def golden_of(d):
    c = os.path.join(d, 'cmds.txt')
    if not os.path.isfile(c):
        return None
    for line in open(c):
        m = re.search(r'golden cache hit (/[^)]*)', line)
        if m and os.path.isdir(m.group(1)):
            g = os.path.join(m.group(1), 'golden.uhdm')
            return g if os.path.isfile(g) else None
    return None

def main():
    wd, out = sys.argv[1], sys.argv[2]
    rows, scanned = [], 0
    for mode in sorted(os.listdir(wd)):
        md = os.path.join(wd, mode)
        if not os.path.isdir(md):
            continue
        for t in sorted(os.listdir(md)):
            d = os.path.join(md, t)
            f = os.path.join(d, 'slang.uhdm')
            if not os.path.isfile(f):
                continue
            scanned += 1
            ours = hcidx(f)
            if not ours:
                continue
            why = []
            if any(dec is not None and not re.fullmatch(r'\d+', dec)
                   for dec, _, _ in ours):
                why.append('A:rawtext')
            if any(ct == '9' and sz == '64' for _, ct, sz in ours):
                g = golden_of(d)
                if g:
                    gold = hcidx(g) or []
                    if any(ct == '7' and sz == '64' for _, ct, sz in gold):
                        why.append('B:goldenct7')
            if why:
                rows.append('PREDICT %s/%s  %s' % (mode, t, ','.join(why)))
    with open(out, 'w') as fh:
        fh.write('\n'.join(rows))
        fh.write('\n-- scanned=%d predicted=%d\n' % (scanned, len(rows)))
    print('scanned=%d predicted=%d' % (scanned, len(rows)))

main()
