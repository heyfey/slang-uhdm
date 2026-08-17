#!/usr/bin/env python3
"""r10uvm89 — join a ct89cen golden file to a ct89cen ours file on the
FILE|SPAN key and classify the NAME disagreement.  MEASUREMENT-ONLY.

LHS is ALWAYS golden.  Prints, per (golden-name-shape, our-name-shape) class:
  count, one witness, the IDXK column of both sides.

Classes:
  AGREE            same NAME text
  BRK-EMPTIED      golden's bracket text is EMPTY where ours has text
  BRK-DROPPED      golden has NO bracket where ours has one
  BRK-FOLDED       both non-empty, texts differ
  OTHER            any other name difference
  MISSING-OURS / EXTRA-OURS   key on one side only
usage: join89.py <g> <o> <tag> [--rows]
"""
import sys, re, collections

def load(p):
    d = {}
    for ln in open(p):
        ln = ln.rstrip("\n")
        if not ln: continue
        key, rest = ln.split("\t", 1)
        # OUR hier_paths carry an EMPTY vpiFile (dump paths embed the workdir and
        # our emitter does not set it on a hier_path), so the JOIN KEY IS THE
        # SPAN ALONE.  Collisions are handled by pairing in sorted order within
        # a span and are reported by the paired-rows total.
        key = key.split("|", 1)[1]
        f = dict(x.split("=", 1) for x in rest.split("\t"))
        d.setdefault(key, []).append(f)
    return d

def brks(name):
    """the list of bracket groups in a name, in order"""
    out, i = [], 0
    while i < len(name):
        if name[i] == '[':
            d, st = 0, i
            while i < len(name):
                if name[i] == '[': d += 1
                elif name[i] == ']':
                    d -= 1
                    if d == 0: i += 1; break
                i += 1
            out.append(name[st:i])
        else:
            i += 1
    return out

def strip_brk(name):
    out, i = [], 0
    while i < len(name):
        if name[i] == '[':
            d = 0
            while i < len(name):
                if name[i] == '[': d += 1
                elif name[i] == ']':
                    d -= 1
                    if d == 0: i += 1; break
                i += 1
        else:
            out.append(name[i]); i += 1
    return "".join(out)

def classify(g, o):
    if g == o: return "AGREE"
    if strip_brk(g) != strip_brk(o): return "OTHER"
    bg, bo = brks(g), brks(o)
    if len(bg) != len(bo):
        return "BRK-DROPPED" if len(bg) < len(bo) else "BRK-ADDED"
    if all(x == "[]" or x == y for x, y in zip(bg, bo)) and any(x == "[]" for x in bg):
        return "BRK-EMPTIED"
    return "BRK-FOLDED"

g, o, tag = sys.argv[1], sys.argv[2], sys.argv[3]
rows = "--rows" in sys.argv
G, O = load(g), load(o)
cls = collections.Counter()
wit = {}
for k in sorted(set(G) | set(O)):
    if k not in O:
        for f in G[k]: cls["MISSING-OURS"] += 1; wit.setdefault("MISSING-OURS", (k, f["NAME"], "-", f.get("IDXK","-"), "-"))
        continue
    if k not in G:
        for f in O[k]: cls["EXTRA-OURS"] += 1; wit.setdefault("EXTRA-OURS", (k, "-", f["NAME"], "-", f.get("IDXK","-")))
        continue
    # pair up in order (same key can repeat for repeated spans)
    for i in range(max(len(G[k]), len(O[k]))):
        if i >= len(G[k]): cls["EXTRA-OURS"] += 1; continue
        if i >= len(O[k]): cls["MISSING-OURS"] += 1; continue
        gf, of = G[k][i], O[k][i]
        c = classify(gf["NAME"], of["NAME"])
        cls[c] += 1
        if rows and c != "AGREE":
            print("%s\t%s\tG=%s\tO=%s\tGIDX=%s\tOIDX=%s\tGLV=%s\tSITE=%s" %
                  (c, k, gf["NAME"], of["NAME"], gf.get("IDXK","-"),
                   of.get("IDXK","-"), gf.get("LVAL","-"), gf.get("SITE","-")))
        wit.setdefault(c, (k, gf["NAME"], of["NAME"], gf.get("IDXK","-"), of.get("IDXK","-")))
tot = sum(cls.values())
print("== %s  G=%d O=%d paired-rows=%d" % (tag, sum(len(v) for v in G.values()),
                                           sum(len(v) for v in O.values()), tot))
for c, n in cls.most_common():
    k, gn, on, gi, oi = wit[c]
    print("  %-14s %6d   e.g. %s\n       G=%s\n       O=%s\n       GIDX=%s\n       OIDX=%s" %
          (c, n, k, gn, on, gi, oi))
