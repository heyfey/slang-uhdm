#!/usr/bin/env python3
"""r11u21 L1 — the SOURCE-keyed a-priori mover prediction (a deliberate
SUPERSET).  Nothing in a database records that an initializer was WRITTEN as a
member read once the elaborated view folded it, so the first prediction is made
from the sources: every `parameter` / `localparam` declaration whose written
initializer contains a DOTTED read `X.Y`.

    predL1_21.py <root dir> [<root dir> ...]
prints one line per test directory that carries at least one such declaration.
"""
import os, re, sys

DECL = re.compile(
    r'\b(?:localparam|parameter)\b[^;,()]*?=\s*([^;,]*)', re.S)
DOT = re.compile(r'\b[A-Za-z_]\w*\s*\.\s*[A-Za-z_]\w*')
EXT = ('.sv', '.svh', '.v', '.vh')

def scan(path):
    try:
        txt = open(path, errors='replace').read()
    except OSError:
        return False
    txt = re.sub(r'//[^\n]*', '', txt)
    txt = re.sub(r'/\*.*?\*/', '', txt, flags=re.S)
    for m in DECL.finditer(txt):
        if DOT.search(m.group(1)):
            return True
    return False

hits = {}
for root in sys.argv[1:]:
    for dirpath, _dirs, files in os.walk(root):
        for f in files:
            if f.endswith(EXT) and scan(os.path.join(dirpath, f)):
                # the TEST is the directory directly under `root`
                rel = os.path.relpath(dirpath, root).split(os.sep)[0]
                hits.setdefault(rel, set()).add(f)
for k in sorted(hits):
    print('%s  %s' % (k, ' '.join(sorted(hits[k]))))
print('[S] dirs=%d' % len(hits))
