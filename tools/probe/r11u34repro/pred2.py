#!/usr/bin/env python3
"""r11u34 SHAPE LISTER 2 — the K7 TYPESPEC face.

For every test in a workdir, list each ELABORATED-PACKAGE (|uhdmtopPackages:)
param_assign whose Rhs is an assignment-pattern operation, recording on BOTH
sides whether the op carries a vpiTypespec and whether its operands are
tagged_pattern (TAG) or flat (FLAT).  A row where GOLDEN is `ts=1 FLAT` and
OURS is `ts=0 TAG` is the iface_zero_width_field cell.
usage: pred2.py <workdir> <mode>"""
import os, re, subprocess, sys

DUMP = '/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump'

def rows(txt):
    out = {}
    lines = txt.splitlines()
    sect = None
    i = 0
    while i < len(lines):
        ln = lines[i]
        m = re.match(r'^\|(uhdm\w+):', ln)
        if m:
            sect = m.group(1); i += 1; continue
        m = re.match(r'^(\s*)\\_param_assign: , (line:[\d:]+)', ln)
        if not m or sect != 'uhdmtopPackages':
            i += 1; continue
        ind = len(m.group(1)); loc = m.group(2)
        j = i + 1; blk = []
        while j < len(lines):
            l2 = lines[j]
            k = len(l2) - len(l2.lstrip())
            if k <= ind and l2.strip():
                break
            blk.append(l2); j += 1
        rpos = None; rind = None
        for a, l2 in enumerate(blk):
            if l2.strip() == '|vpiRhs:' and a + 1 < len(blk):
                rpos = a + 1; rind = len(blk[a+1]) - len(blk[a+1].lstrip()); break
        if rpos is not None and '\\_operation:' in blk[rpos]:
            ts = 0; op75 = False; tag = 0; flat = 0
            for l2 in blk[rpos+1:]:
                k = len(l2) - len(l2.lstrip())
                if k <= rind and l2.strip():
                    break
                s = l2.lstrip()
                if k == rind + 2 and s.startswith('|vpiTypespec:'):
                    ts = 1
                if k == rind + 2 and s.startswith('|vpiOpType:75'):
                    op75 = True
                if k == rind + 4 and s.startswith('\\_tagged_pattern:'):
                    tag += 1
                if k == rind + 4 and s.startswith('\\_constant:'):
                    flat += 1
            if op75:
                out[loc] = 'ts=%d tag=%d flat=%d' % (ts, tag, flat)
        i = j
    return out

wd, mode = sys.argv[1], sys.argv[2]
root = os.path.join(wd, mode)
for d in sorted(os.listdir(root)):
    p = os.path.join(root, d)
    if not os.path.isdir(p): continue
    name = d.rsplit('-', 1)[0]
    cmds = os.path.join(p, 'cmds.txt')
    g = None
    if os.path.exists(cmds):
        m = re.search(r'golden cache hit (/\S+?)\)', open(cmds).read())
        if m: g = os.path.join(m.group(1), 'golden.uhdm')
    o = os.path.join(p, 'slang.uhdm')
    dd = {}
    for tag, path in (('G', g), ('O', o)):
        if not path or not os.path.exists(path): continue
        try:
            r = subprocess.run([DUMP, path], capture_output=True, text=True, timeout=600)
        except subprocess.TimeoutExpired:
            continue
        if r.returncode: continue
        dd[tag] = rows(r.stdout)
    if 'G' not in dd or 'O' not in dd: continue
    for loc in sorted(set(dd['G']) | set(dd['O'])):
        gv = dd['G'].get(loc, 'ABSENT'); ov = dd['O'].get(loc, 'ABSENT')
        if gv != ov:
            print('%s %s %s  G[%s]  O[%s]' % (name, mode, loc, gv, ov))
