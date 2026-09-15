#!/usr/bin/env python3
# r11u43 — SHAPE LISTER: for each grid arm, the NET/VAR objects of the
# elaborated module_inst with their typespec chain, so the target shape is read
# from the database and not guessed.
import re, sys, subprocess, os
DUMP = "/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump"

def indent(l): return len(l) - len(l.lstrip(' '))

def run(db):
    return subprocess.run([DUMP, db], capture_output=True, text=True, timeout=600).stdout

NET = re.compile(r'\\_(\w*(?:net|var))(?:_\w+)?: \(([^)]*)\)')

def arm(db):
    lines = run(db).split('\n')
    out = []
    for i, ln in enumerate(lines):
        m = re.search(r'\\_([a-z_]+): \(([^)]*)\)', ln)
        if not m: continue
        kind, nm = m.group(1), m.group(2)
        if not (kind.endswith('_net') or kind.endswith('_var') or kind == 'net' or kind == 'variables'):
            continue
        base = indent(ln)
        # only top-level declarations (children of module_inst) — depth 2
        if base != 2: continue
        ts = []
        j = i + 1
        while j < len(lines) and indent(lines[j]) > base:
            s = lines[j].strip()
            mm = re.match(r'\\_(\w*typespec): ?(.*)', s)
            if mm: ts.append(mm.group(1))
            mm = re.match(r'\|vpiSize:(-?\d+)', s)
            if mm and len(ts) == 0: pass
            j += 1
        out.append('%s %s ts=[%s]' % (kind, nm.split('.')[-1], ' -> '.join(ts)))
    return out

if __name__ == '__main__':
    root = sys.argv[1]
    for a in sorted(os.listdir(root)):
        db = os.path.join(root, a, 'slpp_all', 'surelog.uhdm')
        if not os.path.exists(db):
            print(a, 'NODB'); continue
        for r in arm(db):
            print(a, r)
