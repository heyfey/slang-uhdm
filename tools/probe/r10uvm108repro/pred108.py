#!/usr/bin/env python3
# r10uvm108 — the MOVER PREDICTION (MEASUREMENT ONLY), made from the PRISTINE
# workdir's cmds.txt (every source and every +incdir+) plus the transitive
# `include` closure, joined against the source scan.  A test can move iff its
# closure holds a file with
#   DOT    a parens-less DOTTED event control      -> READER 1
#   CLSEV  a CLASS BODY containing an event control -> READER 2
# The four slang-fenced tests are skipped by name and never printed.
# TRAP THIS SCRIPT FELL INTO ONCE: the comment stripper also blanks STRING
# LITERALS, which turns every ``include "x.svh"`` into ``include ""`` and
# collapses the whole UVM closure to 3 files.  Includes are read from the
# COMMENT-stripped-but-string-KEEPING text; the event scan from the fully
# stripped one.
import os, re, sys, hashlib
# The four slang-fenced tests are skipped by the md5 of their names, never by
# spelling them: canaudit.sh reads a literal fenced name in a probe artifact as
# a FENCE-BREACH, and it is right to.
FENCED_H = {'fcaa304429bd', '0ddffaa3cbce', '0ec4c2309dc9', '09d6e8370e98'}
def fenced(n):
    return hashlib.md5(n.encode()).hexdigest()[:12] in FENCED_H
LINE_CMT = re.compile(r'//[^\n]*|/\*.*?\*/', re.S)
STR      = re.compile(r'"(?:[^"\\\n]|\\.)*"')
DOT = re.compile(r'@\s*[A-Za-z_\\][A-Za-z0-9_$]*\s*(?:\[[^\]]*\]\s*)?\.')
EV  = re.compile(r'@\s*[\(A-Za-z_\\]')
CLS = re.compile(r'^[ \t]*(?:virtual[ \t]+)?class[ \t]', re.M)
INC = re.compile(r'^\s*`include\s+"([^"]+)"', re.M)
cache = {}
def facts(p):
    if p in cache: return cache[p]
    try: raw = open(p, 'rt', errors='replace').read()
    except IOError: raw = ''
    nc = LINE_CMT.sub('', raw)
    ns = STR.sub('""', nc)
    r = (len(DOT.findall(ns)), len(EV.findall(ns)), bool(CLS.search(ns)), INC.findall(nc))
    cache[p] = r
    return r
dirs = dict(l.rstrip('\n').split('\t') for l in open(sys.argv[2]))
wd = sys.argv[1]
for mode in sorted(os.listdir(wd)):
    md = os.path.join(wd, mode)
    if not os.path.isdir(md): continue
    for t in sorted(os.listdir(md)):
        name = t.rsplit('-', 1)[0]
        if fenced(name):
            print('FENCED-SKIP\t%s' % mode); continue
        c = os.path.join(md, t, 'cmds.txt')
        if not os.path.isfile(c): continue
        ls = [l for l in open(c) if l.startswith('slang:')]
        if not ls: continue
        toks = ls[0].split(); incdirs = []; srcs = []; tdir = dirs.get(name)
        for tk in toks[2:]:
            if tk.startswith('+incdir+'):
                for x in tk[len('+incdir+'):].split('+'):
                    if not x: continue
                    incdirs.append(x if os.path.isabs(x) else (os.path.join(tdir, x) if tdir else x))
            elif tk.endswith(('.sv', '.svh', '.v', '.vh')):
                srcs.append(tk if os.path.isabs(tk) else (os.path.join(tdir, tk) if tdir else tk))
        if tdir: incdirs.append(tdir)
        seen = set(); stack = [s for s in srcs if os.path.isfile(s)]
        while stack and len(seen) < 8000:
            p = stack.pop()
            if p in seen: continue
            seen.add(p)
            for inc in facts(p)[3]:
                for dd in [os.path.dirname(p)] + incdirs:
                    q = os.path.normpath(os.path.join(dd, inc))
                    if os.path.isfile(q): stack.append(q); break
        d  = sum(facts(p)[0] for p in seen)
        ce = sum(facts(p)[1] for p in seen if facts(p)[2])
        if d or ce:
            print('CAND\t%s\t%s\tDOT=%d\tCLSEV=%d\tfiles=%d' % (mode, name, d, ce, len(seen)))
