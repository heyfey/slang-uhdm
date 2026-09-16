#!/usr/bin/env python3
"""r11u51 HEAD IDENTITY.

Blind one uhdm-cmp head of every id, source location, file name and
identifier, and print its md5 -- so a grid arm's head can be shown to be the
SAME SHAPE as a corpus row's head.  Names are blinded because the arm and the
row are different designs; what is claimed is SHAPE identity (the kind tree
plus the judged scalar fields), never name identity.

Two normalisations are mandatory and each one cost a reading:
  * uhdm-cmp writes the head to STDERR and a copy to STDOUT, so a file that
    merged the two streams (`> f 2>&1`, which is what rowheads.sh does) carries
    each side's `decompile:` block TWICE.  Only the FIRST block per side is
    kept.
  * only the first LHS:/RHS: pair is read; a cmp log may carry more.

  usage: blindhead51.py <cmp log> [<cmp log> ...]
"""
import re, sys, hashlib

def blind(path):
    t = open(path).read()
    i = t.find("LHS:")
    if i < 0:
        return "NO-HEAD", 0
    t = t[i:]
    j = t.find("\nLHS:", 4)
    if j > 0:
        t = t[:j]
    k = t.find("RHS:")
    lhs, rhs = (t[:k], t[k:]) if k > 0 else (t, "")
    def firstblock(s):
        parts = s.split("decompile:")
        return parts[0] + "decompile:" + (parts[1] if len(parts) > 1 else "")
    t = firstblock(lhs) + firstblock(rhs)
    t = re.sub(r'id:\d+', '', t)
    t = re.sub(r'line:\d+:\d+', '', t)
    t = re.sub(r'endln:\d+:\d+', '', t)
    t = re.sub(r'file:[^,]*,', '', t)
    t = re.sub(r'vpiName:.*', 'vpiName:<N>', t)
    t = re.sub(r'vpiFullName:.*', 'vpiFullName:<N>', t)
    t = re.sub(r': \([^)]*\)', ': (<N>)', t)
    t = re.sub(r'[ \t]+', ' ', t)
    lines = [l.strip() for l in t.splitlines() if l.strip()]
    s = "\n".join(lines)
    return hashlib.md5(s.encode()).hexdigest()[:12], len(lines)

for p in sys.argv[1:]:
    h, n = blind(p)
    print(f"{h}  lines={n}  {p}")
