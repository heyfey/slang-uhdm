#!/usr/bin/env python3
# r10uvm110 -- the MOVER PREDICTION (MEASUREMENT ONLY), made A PRIORI from the
# PRISTINE workdir's cmds.txt (every source and every +incdir+) plus the
# transitive `include` closure, joined against a SOURCE scan.  A test can move
# iff its closure holds a file with
#   DOTNEW   a DOTTED simple-assignment lvalue whose RHS is a dynamic-array
#            `new [` -- the one shape § dynArrayNewLvalueBaseOnly110 changes.
# The `this.`/`super.` rooted spelling is counted SEPARATELY (THISNEW) because
# § thisSuperNewAssignNoStmt3 drops those statements outright; a file that has
# only those cannot move.
# The four slang-fenced tests are skipped by the md5 of their names and are
# never spelled here.
# TRAP INHERITED FROM pred108: the comment stripper also blanks STRING
# LITERALS, which turns every ``include "x.svh"`` into ``include ""`` and
# collapses the whole UVM closure to 3 files.  Includes are read from the
# COMMENT-stripped-but-string-KEEPING text; the assignment scan from the fully
# stripped one.
import os, re, sys, hashlib
FENCED_H = {'fcaa304429bd', '0ddffaa3cbce', '0ec4c2309dc9', '09d6e8370e98'}
def fenced(n):
    return hashlib.md5(n.encode()).hexdigest()[:12] in FENCED_H
LINE_CMT = re.compile(r'//[^\n]*|/\*.*?\*/', re.S)
STR      = re.compile(r'"(?:[^"\\\n]|\\.)*"')
# a name, optionally selected, then AT LEAST ONE `.name` (again optionally
# selected), then a BARE `=` (never `<=`, `==`, `+=`, ...) then `new [`.
SEL  = r'(?:\[[^\];]*\])?'
NAME = r'[A-Za-z_$][A-Za-z0-9_$]*'
DOTNEW = re.compile(
    r'(?<![<>=!+\-*/%&|^~])'                 # not part of a compound operator
    r'(' + NAME + SEL + r'(?:\s*\.\s*' + NAME + SEL + r')+)'
    r'\s*=(?!=)\s*new\s*\[')
THISROOT = re.compile(r'^(?:this|super)\b')
INC = re.compile(r'^\s*`include\s+"([^"]+)"', re.M)
cache = {}
def facts(p):
    if p in cache: return cache[p]
    try: raw = open(p, 'rt', errors='replace').read()
    except IOError: raw = ''
    nc = LINE_CMT.sub('', raw)
    ns = STR.sub('""', nc)
    dot = thi = 0
    for m in DOTNEW.finditer(ns):
        if THISROOT.match(m.group(1).strip()): thi += 1
        else: dot += 1
    r = (dot, thi, INC.findall(nc))
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
            for inc in facts(p)[2]:
                for dd in [os.path.dirname(p)] + incdirs:
                    q = os.path.normpath(os.path.join(dd, inc))
                    if os.path.isfile(q): stack.append(q); break
        d  = sum(facts(p)[0] for p in seen)
        th = sum(facts(p)[1] for p in seen)
        if d:
            print('CAND\t%s\t%s\tDOTNEW=%d\tTHISNEW=%d\tfiles=%d' % (mode, name, d, th, len(seen)))
        elif th:
            print('THISONLY\t%s\t%s\tTHISNEW=%d\tfiles=%d' % (mode, name, th, len(seen)))
