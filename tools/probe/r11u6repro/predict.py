#!/usr/bin/env python3
"""r11u6 — a-priori mover PREDICTION for § pkgParamVecTdCloneViewFold +
§ pkgParamDefTsQueryArgRef.

r11u5's predict.py walked each test DIRECTORY, which is blind for the
uhdm2rtlil corpus: a test dir there usually holds only a `project.f` naming
sources that live somewhere else entirely (every `ibex_*` row lists
`../ibex/rtl/*.sv`).  This one RESOLVES the source list the harness itself
builds (project.f, else dut.sv/dut.v; `.sl` for the surelog corpus) and scans
exactly those files plus every file in their directories, so the prediction is
keyed on what the test actually compiles.

Reachability (deliberately OVER-broad -- a name it does not list cannot move).
Two classes, because the law has two independent halves:

  A (fold + query-arg): a `package` declaring a VECTOR typedef
    (`typedef logic/bit/reg [..] n_t;`) whose range mentions an IDENTIFIER,
    and a parameter/localparam written with that typedef's bare name.  Only a
    symbolic bound can change fold state.
  B (alias view): the SAME shape with ANY bound, literal included.  The
    `Typedef_alias` half re-points the clone from the DEF listing's typedef
    object to the ELABORATED one whatever the bound looks like, so `typedef
    logic [7:0] uint8_t;` is reachable even though its bound can never
    unfold.  B is what class A missed on the first census: `typedef_package`
    and `2DParameterOfInstance` moved bytes (arena order only -- their dumps
    are identical) and class A did not name them.
  C (unpacked element): a `package` declaring a parameter with BOTH a packed
    range and an UNPACKED dimension (`parameter logic [MSB:0] A[N]`), whose
    packed bound mentions an identifier.

A test is predicted reachable if it matches ANY class.

usage: predict.py u2r|surelog
"""
import os
import re
import shlex
import sys

HOME = os.path.expanduser('~')
U2R = os.path.join(HOME, 'git-repos', 'uhdm2rtlil', 'test')
SL = os.path.join(HOME, 'git-repos', 'Surelog')

PKG = re.compile(r'\bpackage\s+(\w+)\s*;(.*?)\bendpackage', re.S)
# parameter/localparam logic [..] NAME [..] -- a packed range plus an unpacked dim
UNPK = re.compile(
    r'\b(?:parameter|localparam)\s+(?:logic|bit|reg)\b((?:\s*\[[^;]*?\])+)\s*'
    r'(\w+)\s*((?:\[[^;\]]*\])+)\s*=')
VECTD = re.compile(r'\btypedef\s+(?:logic|bit|reg)\b((?:\s*\[[^;]*?\])+)\s*(\w+)\s*;')
COMMENT = re.compile(r'//[^\n]*|/\*.*?\*/', re.S)
SRCEXT = ('.sv', '.v', '.svh', '.vh')


def scan(path):
    try:
        src = open(path, 'rt', errors='replace').read()
    except OSError:
        return []
    src = COMMENT.sub(' ', src)
    hits = []
    for pm in PKG.finditer(src):
        pname, body = pm.group(1), pm.group(2)
        vtds = {}
        for tm in VECTD.finditer(body):
            dims, tname = tm.group(1), tm.group(2)
            vtds[tname] = dims.strip()
        for tname, dims in vtds.items():
            cls = 'A' if re.search(r'[A-Za-z_]\w*', dims) else 'B'
            for pm2 in re.finditer(
                    r'\b(?:parameter|localparam)\s+' + re.escape(tname) + r'\s+(\w+)',
                    body):
                hits.append((cls, pname, tname, dims.strip(), pm2.group(1)))
        for um in UNPK.finditer(body):
            if re.search(r'[A-Za-z_]\w*', um.group(1)):
                hits.append(('C', pname, '<inline>', um.group(1).strip(),
                             um.group(2)))
    return hits


def files_of_u2r(name):
    d = os.path.join(U2R, name)
    pf = os.path.join(d, 'project.f')
    srcs = []
    if os.path.isfile(pf):
        for raw in open(pf, 'rt', errors='replace'):
            line = raw.strip()
            if not line or line.startswith('#'):
                continue
            srcs.append(line)
    if not srcs:
        for c in ('dut.sv', 'dut.v'):
            if os.path.isfile(os.path.join(d, c)):
                srcs = [c]
                break
    out = set()
    for sdir in {os.path.dirname(os.path.normpath(os.path.join(d, s))) for s in srcs}:
        if os.path.isdir(sdir):
            for fn in os.listdir(sdir):
                if fn.endswith(SRCEXT):
                    out.add(os.path.join(sdir, fn))
    for s in srcs:
        p = os.path.normpath(os.path.join(d, s))
        if os.path.isfile(p):
            out.add(p)
    # ...and the test's OWN tree as well (r11u5's rule), so the union stays
    # over-broad: a source reached only through a +incdir still counts.
    for dp, _, fns in os.walk(d):
        for fn in fns:
            if fn.endswith(SRCEXT):
                out.add(os.path.join(dp, fn))
    return out


def files_of_sl(dirpath, slpath):
    """Every source in the TEST's tree, not just the `.sl`'s own directory.

    A surelog test often keeps its `.sl` in a `sim-*` subdirectory while its
    sources live in a sibling `src/` -- `Earlgrey_0_1/sim-icarus/*.sl` over
    `Earlgrey_0_1/src/...`.  Walking only the `.sl`'s directory reported ZERO
    hits for it, which would have been a silent blind spot rather than a
    reachability result.  Climb to the test root (the child of `tests/` or
    `third_party/tests/`) and walk that.
    """
    root = dirpath
    for anchor in (os.path.join(SL, 'tests'),
                   os.path.join(SL, 'third_party', 'tests')):
        if dirpath.startswith(anchor + os.sep):
            rel = os.path.relpath(dirpath, anchor).split(os.sep)[0]
            root = os.path.join(anchor, rel)
            break
    out = set()
    for dp, _, fns in os.walk(root):
        for fn in fns:
            if fn.endswith(SRCEXT):
                out.add(os.path.join(dp, fn))
    return out


def main():
    which = sys.argv[1] if len(sys.argv) > 1 else 'u2r'
    per = {}
    if which == 'u2r':
        names = [n for n in sorted(os.listdir(U2R))
                 if os.path.isdir(os.path.join(U2R, n))]
        for n in names:
            hits = []
            for f in sorted(files_of_u2r(n)):
                hits += scan(f)
            if hits:
                per[n] = sorted(set(hits))
    else:
        for root in (os.path.join(SL, 'tests'),
                     os.path.join(SL, 'third_party', 'tests')):
            for dp, _, fns in os.walk(root):
                for fn in fns:
                    if not fn.endswith('.sl'):
                        continue
                    n = fn[:-3]
                    hits = []
                    for f in sorted(files_of_sl(dp, os.path.join(dp, fn))):
                        hits += scan(f)
                    if hits:
                        per[n] = sorted(set(hits))
    for t in sorted(per):
        cls = ''.join(sorted({h[0] for h in per[t]}))
        print('%-40s [%-3s] %s' % (t, cls, '; '.join(
            '%s::%s %s %s' % (p, nm, td, dims)
            for _c, p, td, dims, nm in per[t][:4])))
    print('\n-- %s: tests predicted reachable: %d' % (which, len(per)))


if __name__ == '__main__':
    main()
