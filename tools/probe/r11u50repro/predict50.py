#!/usr/bin/env python3
"""r11u50 — THE A-PRIORI MOVER PREDICTION, from the SOURCES both corpora feed
the two producers, before the law binary exists.

§ pkgSubstEncIsReduceTable50 can only move a cell whose value came from a
PACKAGE parameter, so the candidate set is: every test one of whose sources
declares, inside a `package ... endpackage`, a parameter whose initializer
holds an operator on which § dimRedCtExpr79's table and the `paramIntEnc`
marker can disagree — `*`, `**`, a `-` that is not the whole expression's top
operator, a unary `-`, a shift or a bitwise arm over an arithmetic one, or a
NAME whose own initializer holds one (one hop, then two, to a fixpoint).

The prediction is a SUPERSET by construction (it ignores whether the parameter
is ever substituted, and it reads text, not the binder), so the measured mover
set must be a SUBSET of it.  That is the subset argument; the positive control
is the two grids, where the answer is known cell by cell.

usage: predict50.py <corpus-root> [more roots...]     # prints CANDIDATE lines
       predict50.py --files <file> [...]              # one explicit file list
"""
import os, re, sys

PKG = re.compile(r'\bpackage\s+(\w+)\s*;(.*?)\bendpackage\b', re.S)
DECL = re.compile(r'\b(?:parameter|localparam)\b([^;]*);', re.S)
ASSIGN = re.compile(r'(\w+)\s*=\s*([^,;]*(?:\([^()]*\)[^,;]*)*)')
# the operators that make the two predicates disagree, and the ones that make
# the MARKER fire on its own (so a marker-only cell is a candidate too).
ARITH = re.compile(r'\*|/|%')
MINUS = re.compile(r'(?<![\w\)\]])-|-')


def paramdecls(text):
    """(pkgName, paramName, initText) for every package-scoped parameter."""
    out = []
    for pm in PKG.finditer(text):
        body = pm.group(2)
        for dm in DECL.finditer(body):
            seg = dm.group(1)
            # drop a default type spelling's own `[a:b]` ranges before the `=`
            for am in ASSIGN.finditer(seg):
                out.append((pm.group(1), am.group(1), am.group(2).strip()))
    return out


def interesting(init, marked):
    """True when the reduce table and the marker CAN disagree on `init`."""
    t = re.sub(r'//.*', '', init)
    if ARITH.search(t):
        return True
    if '-' in t:
        return True
    for nm in re.findall(r'\b([A-Za-z_]\w*)\b', t):
        if nm in marked:
            return True
    return False


def scan(paths):
    hits = {}
    for p in paths:
        try:
            text = open(p, errors='replace').read()
        except OSError:
            continue
        text = re.sub(r'/\*.*?\*/', ' ', text, flags=re.S)
        decls = paramdecls(text)
        if not decls:
            continue
        marked = set()
        for _ in range(4):
            n = len(marked)
            for pkg, nm, init in decls:
                if interesting(init, marked):
                    marked.add(nm)
            if len(marked) == n:
                break
        for pkg, nm, init in decls:
            if nm in marked:
                hits.setdefault(p, []).append((pkg, nm, ' '.join(init.split())))
    return hits


def srcfiles(root):
    for dp, _d, fs in os.walk(root):
        for fn in fs:
            if fn.endswith(('.sv', '.v', '.svh', '.vh')):
                yield os.path.join(dp, fn)


def main():
    if sys.argv[1] == '--files':
        paths = sys.argv[2:]
    else:
        paths = [p for r in sys.argv[1:] for p in srcfiles(r)]
    hits = scan(paths)
    for p in sorted(hits):
        for pkg, nm, init in hits[p]:
            print('CANDIDATE %s  %s::%s = %s' % (p, pkg, nm, init[:90]))
    print('CANDIDATE_FILES %d  CANDIDATE_PARAMS %d  SCANNED %d' %
          (len(hits), sum(len(v) for v in hits.values()), len(paths)))


main()
