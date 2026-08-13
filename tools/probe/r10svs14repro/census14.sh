#!/usr/bin/env bash
# r10svs14 CARRIER CENSUS — an UPPER BOUND, and it says so.
#
#   usage: ./census14.sh            # both corpora
#
# WHAT IT PREDICTS.  § ifaceDupVarsAreHomeVars14 can only move a database whose
# HOME view's `Variables()` differs from the list the deleted derivation built,
# and the ONLY measured way for that to happen is an interface with an **ANSI
# HEADER PORT whose data type makes a `variables` home object** — a 2-state or
# integer/real/var-typed port (`input bit clock`, `input int n`, `var` ...).  A
# 4-state `wire`/`logic`/`reg` header port makes a `logic_net` and is excluded by
# BOTH the old and the new rule (arm b1 cells c2/c3/c5, EQ on both binaries).
#
# THREE SUFFICIENT CONDITIONS ARE OMITTED, so this is a NECESSARY-condition
# filter, i.e. an UPPER BOUND on the mover set:
#   * the interface must be INSTANTIATED (a def view has no tail dup at all);
#   * some sibling instance must receive the WHOLE interface through a BARE,
#     dot-free connection expression — that is what mints the col-0 tail dup
#     (`wantTailDup`); a modport-qualified `.mon(s.mon)` connection mints none;
#   * slang must accept the file (284 surelog-corpus tests are SLANG_REJECT).
# THE BYTE VERIFIER IS THE AUTHORITY; this runs FIRST only so its answer is on
# the record before the verifier's is known.
#
# TRAPS ENCODED:
#   * an interface header port list SPANS LINES, so the header is parsed with
#     balanced parens rather than grepped line by line;
#   * `bit`/`int` also occur in bodies, in comments and inside other headers, so
#     only the text BETWEEN the interface name's `(` and its matching `)` counts;
#   * a NON-ANSI header (`interface i(clk); input bit clk;`) is NOT a carrier —
#     measured EQ on both binaries (arm b2 cells d1/d2) — so a header whose
#     parens contain no type keyword at all is not counted;
#   * the test dir, not the file, is the unit: a corpus test compiles a filelist.
set -u
ROOT_SL=$HOME/git-repos/Surelog
ROOT_U2R=$HOME/git-repos/uhdm2rtlil/test
export ROOT_SL ROOT_U2R
python3 - <<'PY'
import os, re, sys
KW = r'\b(bit|int|byte|shortint|longint|integer|real|shortreal|realtime|time|var|chandle)\b'
IFACE = re.compile(r'\binterface\s+([A-Za-z_]\w*)\s*(#\s*\()?', re.S)

def header_after(txt, i):
    """The text between the first '(' at/after i and its matching ')'."""
    n = len(txt)
    while i < n and txt[i] not in '(;':
        i += 1
    if i >= n or txt[i] != '(':
        return ''
    d, j = 0, i
    while j < n:
        if txt[j] == '(':
            d += 1
        elif txt[j] == ')':
            d -= 1
            if d == 0:
                return txt[i + 1:j]
        j += 1
    return ''

def strip_comments(t):
    t = re.sub(r'/\*.*?\*/', ' ', t, flags=re.S)
    return re.sub(r'//[^\n]*', ' ', t)

def carrier(d):
    for root, _, files in os.walk(d):
        for f in files:
            if not f.endswith(('.sv', '.v', '.svh', '.vh')):
                continue
            try:
                t = strip_comments(open(os.path.join(root, f), errors='replace').read())
            except OSError:
                continue
            for m in IFACE.finditer(t):
                # skip the parameter list if one is present
                i = m.end()
                if m.group(2):
                    d0, j = 1, m.end()
                    while j < len(t) and d0:
                        d0 += (t[j] == '(') - (t[j] == ')')
                        j += 1
                    i = j
                h = header_after(t, i)
                if h and re.search(KW, h):
                    return (f, m.group(1), ' '.join(h.split())[:60])
    return None

def sweep(label, dirs):
    n = t = 0
    print('== ' + label)
    for d in dirs:
        t += 1
        c = carrier(d)
        if c:
            n += 1
            print('   %-28s %s: interface %s(%s)' % (os.path.basename(d), c[0], c[1], c[2]))
    print('   -> %d of %d test dirs' % (n, t))
    return n

import glob
sl = sorted({os.path.dirname(p) for p in
             glob.glob(os.environ['ROOT_SL'] + '/tests/*/*.sl') +
             glob.glob(os.environ['ROOT_SL'] + '/third_party/tests/*/*.sl')})
u2r = sorted(p for p in glob.glob(os.environ['ROOT_U2R'] + '/*') if os.path.isdir(p))
a = sweep('surelog corpus (one dir per <Name>.sl)', sl)
b = sweep('uhdm2rtlil corpus', u2r)
print('UPPER BOUND: %d test dirs across both corpora.' % (a + b))
PY
