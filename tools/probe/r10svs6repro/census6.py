#!/usr/bin/env python3
"""r10svs6 CENSUS — every FIXED-SIZE unpacked-array CLASS PROPERTY in the corpora,
so the byte-verifier's mover set can be PREDICTED before it is measured.

    usage: census6.py [-v]

WHY IT SCANS third_party/UVM TOO: r10svs4 predicted 1 mover and its verifier
found 9, because the census covered `Surelog/tests`, `Surelog/third_party/tests`
and `uhdm2rtlil/test` and OMITTED `Surelog/third_party/UVM`, which the four UVM
tests compile in.  A source census over test directories is not a blast radius
when the tests vendor a library.

WHAT IT MATCHES, and what it therefore CANNOT know: a declaration INSIDE a class
body whose declarator carries a bracket that is neither empty (`[]`, dynamic) nor
`[$]` (queue) nor a type/`*` index (associative).  It is a TEXT scan:
  * it tracks class bodies by counting `class`...`endclass` (skipping `virtual
    class` and `typedef class` forward declarations, and `extern`), so a property
    outside any class is never counted;
  * `[N]` with a NUMBER is certainly a fixed dim; `[NAME]` is AMBIGUOUS — a
    parameter-sized fixed dim (`[DEPTH]`) or an ASSOCIATIVE index typed by
    `NAME`.  Both are reported, separately, and the ambiguous bucket is an UPPER
    bound on that half.
  * a `rand`/`local`/`protected`/`static`/`const` qualifier prefix is allowed.
It cannot see a property whose fixed dim comes from a TYPEDEF (`barr_t x;`), which
is exactly the shape § fixedClassPropIsArrayVar6 GATES OUT, so that omission is
aligned with the law rather than a hole in it.
"""
import os
import re
import sys

HOME = os.path.expanduser('~')
ROOTS = [os.path.join(HOME, 'git-repos', 'Surelog', 'tests'),
         os.path.join(HOME, 'git-repos', 'Surelog', 'third_party', 'tests'),
         os.path.join(HOME, 'git-repos', 'Surelog', 'third_party', 'UVM'),
         os.path.join(HOME, 'git-repos', 'uhdm2rtlil', 'test')]
EXT = ('.sv', '.svh', '.v', '.vh')

CLASS_OPEN = re.compile(r'(^|[^\w])class\s+\w+')
CLASS_FWD = re.compile(r'typedef\s+class|extern\s')
CLASS_CLOSE = re.compile(r'(^|[^\w])endclass')
# <qualifiers> <type...> <name> [ <dim> ] ... ;
DECL = re.compile(r'^\s*(?:(?:rand|randc|local|protected|static|const|virtual)\s+)*'
                  r'[A-Za-z_][\w:#()\s,.\[\]$-]*?'
                  r'\b(?P<name>[A-Za-z_]\w*)\s*'
                  r'(?P<dims>(?:\[[^\];]*\]\s*)+);')


def classify(dims):
    """('fixed'|'ambig'|None, the dim text) for the OUTERMOST bracket set."""
    inner = re.findall(r'\[([^\]]*)\]', dims)
    if not inner:
        return None
    kinds = []
    for d in inner:
        d = d.strip()
        if d == '' or d == '$' or d == '*':
            kinds.append('unsized')
        elif re.fullmatch(r'-?\d+(\s*:\s*-?\d+)?', d):
            kinds.append('fixed')
        elif re.fullmatch(r'[\w:$.]+(\s*[-+]\s*\d+)?(\s*:\s*[\w:$.]+(\s*[-+]\s*\d+)?)?', d):
            kinds.append('ambig')
        else:
            kinds.append('ambig')
    if 'unsized' in kinds:
        return None            # the hybrids: a different law (residue R2)
    return 'fixed' if all(k == 'fixed' for k in kinds) else 'ambig'


def main():
    verbose = '-v' in sys.argv[1:]
    hits = {'fixed': [], 'ambig': []}
    for root in ROOTS:
        if not os.path.isdir(root):
            print('MISSING ROOT: %s' % root)
            return 6
        for dirpath, _dn, fns in os.walk(root):
            for fn in fns:
                if not fn.endswith(EXT):
                    continue
                p = os.path.join(dirpath, fn)
                depth = 0
                try:
                    lines = open(p, errors='replace').read().split('\n')
                except OSError:
                    continue
                for ln, raw in enumerate(lines, 1):
                    line = re.sub(r'//.*$', '', raw)
                    if CLASS_CLOSE.search(line):
                        depth = max(0, depth - 1)
                    if CLASS_OPEN.search(line) and not CLASS_FWD.search(line):
                        depth += 1
                        continue
                    if depth <= 0:
                        continue
                    m = DECL.match(line)
                    if not m:
                        continue
                    k = classify(m.group('dims'))
                    if k:
                        hits[k].append((p, ln, line.strip()))
    for k in ('fixed', 'ambig'):
        print('== %s-dim class properties: %d' % (k, len(hits[k])))
        per = {}
        for (p, _ln, _t) in hits[k]:
            if '/third_party/UVM/' in p:
                t = '<UVM-LIBRARY>'
            else:
                m = re.search(r'/(?:third_party/)?tests/([^/]+)/', p)
                m2 = re.search(r'/uhdm2rtlil/test/([^/]+)/', p)
                t = m.group(1) if m else ('u2r:' + m2.group(1) if m2 else p)
            per[t] = per.get(t, 0) + 1
        for t, n in sorted(per.items(), key=lambda kv: -kv[1]):
            print('   %4d  %s' % (n, t))
        if verbose:
            for (p, ln, t) in hits[k]:
                print('      %s:%d: %s' % (p, ln, t))
    return 0


if __name__ == '__main__':
    sys.exit(main())
