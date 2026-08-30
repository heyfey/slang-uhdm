#!/usr/bin/env python3
"""r10uvm161 — score ONE grid arm, golden vs a binary, cell by cell.
MEASUREMENT ONLY; the official `uhdm-cmp` is the sole judge.
G is ALWAYS golden (Surelog); O is ALWAYS ours.

ct161cen prints three cell families and this scorer keys each on an IDENTITY
both producers can spell, never on an id and never on a full name:

  REF  key = (view, ref kind, name, line:col, ancestor-kind chain)
       value = the SET of `ACT=` tokens seen under that key.
       A SET, not a multiset: one source reference can appear twice in a
       database (a package method is listed both in its class and under its
       package-qualified definition) and the two producers materialise
       different NUMBERS of those copies.  That multiplicity belongs to a
       different law; the ACT VALUE is what this one moves.
  VAR  key = (view, owning scope, var kind, name, line:col)
       value = the SET of `auto=` stamps — the § 139 column.
  CNT  key = (view, scope kind:name@span)
       value = the SET of `vars=` LISTING COUNTS.  Every scope emits one,
       INCLUDING a scope that lists nothing, so "we list where golden lists
       none" (the AWAY direction the brief asks to be scored explicitly) is a
       DIFF and never a silent gap.

usage: score161.py <cen.g.txt> <cen.o.txt> [--only REF|VAR|CNT] [substring ...]
"""
import sys, collections

argv = sys.argv[1:]
# --nospan drops the line:col from every key.  Spans are the human handle, NOT
# what the judge reads (RESUME.md §9: no generated `Compare` reads a file, line
# or column), and one PRE-EXISTING span residue of a different law — the
# elements of a `this.<prop>` hier_path, which we anchor at 0:0 and at the
# `this` token while Surelog anchors both at the property token — would
# otherwise pair those cells wrongly and read as ONLY-G / ONLY-O when their
# VALUES agree exactly.
NOSPAN = "--nospan" in argv
only = None
if "--only" in argv:
    i = argv.index("--only")
    only = argv[i + 1]
    del argv[i:i + 2]
args = [a for a in argv if not a.startswith("--")]


def load(path):
    m = collections.defaultdict(set)
    for ln in open(path):
        f = ln.rstrip("\n").split("|")
        if len(f) < 3:
            continue
        fam, tag = f[0], f[1]
        view = tag.split(".", 1)[1] if "." in tag else tag
        span = "-" if NOSPAN else None
        if fam == "REF" and len(f) >= 7:
            m[("REF", view, f[2], f[3], span or f[4], f[5])].add(f[6])
        elif fam == "VAR" and len(f) >= 7:
            m[("VAR", view, f[2], f[3], span or f[4], f[5])].add(f[6])
        elif fam == "CNT" and len(f) >= 4:
            m[("CNT", view, f[2])].add(f[3])
    return m


g = load(args[0])
o = load(args[1])
pref = tuple(args[2:])
same = diff = og = oo = 0
for k in sorted(set(g) | set(o), key=lambda t: tuple(map(str, t))):
    if only and k[0] != only:
        continue
    if pref and not any(p in "|".join(map(str, k)) for p in pref):
        continue
    gv = g.get(k)
    ov = o.get(k)
    if gv is None:
        oo += 1
        print(f"ONLY-O\t{k}\t{sorted(ov)}")
    elif ov is None:
        og += 1
        print(f"ONLY-G\t{k}\t{sorted(gv)}")
    elif gv == ov:
        same += 1
        print(f"SAME\t{k}\t{sorted(gv)}")
    else:
        diff += 1
        print(f"DIFF\t{k}\n     G={sorted(gv)}\n     O={sorted(ov)}")
print(f"-- SAME={same} DIFF={diff} ONLY-G={og} ONLY-O={oo}")
