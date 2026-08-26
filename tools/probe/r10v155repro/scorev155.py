#!/usr/bin/env python3
"""r10uvm155 — score ONE grid arm: golden vs a binary, cell by cell.
MEASUREMENT ONLY; the official uhdm-cmp is the judge.  LHS/G is ALWAYS golden.

Rows are keyed on (view, owner, span, name) and the payload compared is
(var kind, typespec kind, typespec name, typespec vpiInstance, typespec span).
A cell present on one side only is printed as ONLY-G / ONLY-O and COUNTED — a
scorer that silently drops half a pair reads as perfection.

usage: score155.py <cen.g.txt> <cen.o.txt> [name-prefix ...]
"""
import sys, collections

def load(p):
    m = collections.defaultdict(set)
    for ln in open(p):
        f = ln.rstrip("\n").split("\t")
        if len(f) < 14 or f[1] in ("REF", "CALL", "TP"):
            continue
        m[(f[2], f[5], f[6], f[7])].add((f[8], f[10], f[11], f[12], f[13]))
    return m

g = load(sys.argv[1]); o = load(sys.argv[2])
pref = tuple(sys.argv[3:])
same = diff = og = oo = 0
for k in sorted(set(g) | set(o)):
    if pref and not k[3].startswith(pref):
        continue
    gv = sorted(g.get(k, [])); ov = sorted(o.get(k, []))
    if not gv:
        oo += 1; print(f"ONLY-O\t{k}\t{ov}"); continue
    if not ov:
        og += 1; print(f"ONLY-G\t{k}\t{gv}"); continue
    if gv == ov:
        same += 1; print(f"SAME\t{k[0]:9s} {k[3]:18s} {gv}")
    else:
        diff += 1
        print(f"DIFF\t{k[0]:9s} {k[3]:18s}\n     G={gv}\n     O={ov}")
print(f"-- SAME={same} DIFF={diff} ONLY-G={og} ONLY-O={oo}")
