#!/usr/bin/env python3
"""r11u5 — a-priori mover PREDICTION for § pkgParamVecTdCloneViewFold.

The law only reaches a parameter that is
  * declared inside a `package` ... `endpackage`, and
  * typed by the NAME of a VECTOR typedef (`typedef logic/bit/reg [..] n_t;`)
    declared in that same package, and
  * whose typedef's range is SYMBOLIC (mentions an identifier) -- a literal
    bound like [31:0] folds to the same constant either way, so it can never
    move.

Purely syntactic, deliberately OVER-broad (it ignores `ifdef and any
non-package typedef home): a name it does not list cannot move, which is the
direction a prediction has to be safe in.
"""
import os
import re
import sys

PKG = re.compile(r'\bpackage\s+(\w+)\s*;(.*?)\bendpackage', re.S)
# typedef logic [A-1:0] n_t;  /  typedef bit [W:0][X:0] n_t;
VECTD = re.compile(r'\btypedef\s+(?:logic|bit|reg)\b((?:\s*\[[^;]*?\])+)\s*(\w+)\s*;')
COMMENT = re.compile(r'//[^\n]*|/\*.*?\*/', re.S)


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
            if re.search(r'[A-Za-z_]\w*', dims):      # a symbolic bound
                vtds[tname] = dims.strip()
        if not vtds:
            continue
        for tname, dims in vtds.items():
            # parameter/localparam <tname> NAME
            for pm2 in re.finditer(
                    r'\b(?:parameter|localparam)\s+' + re.escape(tname) +
                    r'\s+(\w+)', body):
                hits.append((pname, tname, dims, pm2.group(1)))
    return hits


if __name__ == '__main__':
    roots = sys.argv[1:]
    per_test = {}
    for root in roots:
        for name in sorted(os.listdir(root)):
            d = os.path.join(root, name)
            if not os.path.isdir(d):
                continue
            found = []
            for dp, _, fns in os.walk(d):
                for fn in fns:
                    if fn.endswith(('.sv', '.v', '.svh', '.vh')):
                        found += scan(os.path.join(dp, fn))
            if found:
                per_test[name] = sorted(set(found))
    for t in sorted(per_test):
        print('%-34s %s' % (t, '; '.join(
            '%s::%s %s %s' % (p, n, td, dims) for p, td, dims, n in per_test[t][:6])))
    print('\n-- tests predicted reachable: %d' % len(per_test))
