#!/usr/bin/env python3
"""r11u32 — A-PRIORI mover prediction for LAW C
(§ typeParamArgNetNeedsNonAnsi32), from the SOURCES only.

Law C only ADDS a def-view `vpiTypespec` back to a net whose typedef is ALSO
passed as a child instance's `type` argument, and only where the holder's
header is ANSI.  So a design can move iff some source both
  (a) passes a type as a named `type` argument at an instantiation —
      `#( ... .NAME(TYPE) ... )` where TYPE is a locally declared typedef —
  and (b) declares a net of that same TYPE.
The scan cannot resolve scopes or tell an ANSI header from a non-ANSI one, so
it over-predicts; over-prediction is the safe direction (a mover NOT on the
list is unexplained and fails the pass).

usage: predictC.py <corpus-root> [<corpus-root> ...]
"""
import os, re, sys

def typedef_names(txt):
    """Every typedef's declared NAME: scan from each `typedef` keyword to the
    `;` that ends the statement at brace depth 0, and take the last identifier
    before it.  A regex over `[^;]*` cannot do this — a struct or enum body
    holds its own `;` and the match dies inside the braces, which is what made
    the first version of this predictor MISS its own positive control."""
    out = set()
    for m in re.finditer(r'\btypedef\b', txt):
        i, depth = m.end(), 0
        while i < len(txt):
            c = txt[i]
            if c in '{(':
                depth += 1
            elif c in '})':
                depth -= 1
            elif c == ';' and depth <= 0:
                break
            i += 1
        stmt = txt[m.end():i]
        ids = re.findall(r'[A-Za-z_]\w*', re.sub(r'\[[^\]]*\]', ' ', stmt))
        if ids:
            out.add(ids[-1])
    return out

TYPEARG = re.compile(r'\.\s*\w+\s*\(\s*([A-Za-z_]\w*)\s*\)')
NETDECL = re.compile(r'(?:^|;|\)|\bbegin\b)\s*(\w+)\s+\w+\s*(?:=[^;]*)?;', re.M)
SRC_EXT = ('.sv', '.v', '.svh', '.vh')

def scan_dir(d, budget=4000):
    tds, args, nets, n = set(), set(), set(), 0
    for root, _dirs, files in os.walk(d):
        for f in files:
            if not f.endswith(SRC_EXT):
                continue
            n += 1
            if n > budget:
                break
            try:
                txt = open(os.path.join(root, f), errors='replace').read()
            except OSError:
                continue
            tds |= typedef_names(txt)
            for m in TYPEARG.finditer(txt):
                args.add(m.group(1))
            for m in NETDECL.finditer(txt):
                nets.add(m.group(1))
    return tds & args & nets

def surelog_tests(fencefile):
    """The SURELOG corpus is keyed one test per *.sl, not one per top-level
    directory, so it needs its own walk.  Fenced names are dropped from the
    OUTPUT; nothing here runs anything."""
    root = os.path.expanduser('~/git-repos/Surelog')
    fenced = {l.strip() for l in open(fencefile) if l.strip()} if fencefile else set()
    tests = {}
    for r in (os.path.join(root, 'tests'),
              os.path.join(root, 'third_party', 'tests')):
        for dp, _d, fs in os.walk(r):
            for f in fs:
                if f.endswith('.sl'):
                    tests[f[:-3]] = dp
    hits = {}
    for n, d in sorted(tests.items()):
        if n in fenced:
            continue
        h = scan_dir(d)
        if h:
            hits[n] = sorted(h)
    return len(tests), hits

def main():
    if sys.argv[1:2] == ['--sl']:
        n, hits = surelog_tests(sys.argv[2] if len(sys.argv) > 2 else None)
        for k, v in sorted(hits.items()):
            print(f'{k}\t{",".join(v[:8])}{" ..." if len(v) > 8 else ""}')
        print(f'-- TESTS: {n}   PREDICTED CANDIDATES (law C): {len(hits)}')
        return
    hits = {}
    for rootdir in sys.argv[1:]:
        for name in sorted(os.listdir(rootdir)):
            d = os.path.join(rootdir, name)
            if os.path.isdir(d):
                h = scan_dir(d)
                if h:
                    hits[name] = sorted(h)
    for k, v in sorted(hits.items()):
        print(f'{k}\t{",".join(v[:10])}{" ..." if len(v) > 10 else ""}')
    print(f'-- PREDICTED CANDIDATES (law C): {len(hits)}')

main()
