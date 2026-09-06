#!/usr/bin/env python3
"""r10v171repro/vscore171.py — DIRECTIONAL scorer for a vgrid171 workdir.

MEASUREMENT ONLY; the official uhdm-cmp is the sole judge.

Joins the three ct171pred listings of ONE view as MULTISETS keyed on
(line:col, kind) — the home chain is EVIDENCE, never a key, because the two
producers label a clone's home differently (RESUME §9).  For each key it
reports how many copies are BOUND on each side, and classifies:

  OVER   patched binds where golden does NOT  (AWAY-GOLDEN: a REGRESSION face)
  UNDER  golden binds where patched does not  (a residue / miss)
  FIXED  pristine differed, patched agrees
  BROKE  pristine agreed, patched differs     (pristine-right -> patched-wrong)

usage: vscore171.py <workdir> <view>
"""
import sys, os, re
from collections import Counter, defaultdict

W, V = sys.argv[1], sys.argv[2]

def load(tag):
    p = os.path.join(W, f"pred.{tag}.{V}.txt")
    rows = defaultdict(lambda: [0, 0])   # key -> [bound, bare]
    if not os.path.exists(p):
        return rows
    for ln in open(p):
        m = re.match(r"\s*\[[^\]]*\]\s+(\d+):(\d+)\s+(\S+)\s+(BOUND|BARE)\s+fn=(\S+)", ln)
        if not m:
            continue
        key = (int(m.group(1)), int(m.group(2)), m.group(3), m.group(5))
        rows[key][0 if m.group(4) == "BOUND" else 1] += 1
    return rows

g, a, b = load("g"), load("a"), load("b")
keys = sorted(set(g) | set(a) | set(b))
over = under = fixed = broke = agree = 0
lines = []
for k in keys:
    G, A, B = g.get(k, [0, 0]), a.get(k, [0, 0]), b.get(k, [0, 0])
    okA, okB = (G == A), (G == B)
    if okB:
        agree += 1
        if not okA:
            fixed += 1
            lines.append(f"  FIXED  {k[0]}:{k[1]} {k[2]} fn={k[3]} g={G} a={A} b={B}")
        continue
    if okA:
        broke += 1
        lines.append(f"  BROKE  {k[0]}:{k[1]} {k[2]} fn={k[3]} g={G} a={A} b={B}")
    if B[0] > G[0]:
        over += 1
        lines.append(f"  OVER   {k[0]}:{k[1]} {k[2]} fn={k[3]} g={G} a={A} b={B}")
    elif B[0] < G[0]:
        under += 1
        lines.append(f"  UNDER  {k[0]}:{k[1]} {k[2]} fn={k[3]} g={G} a={A} b={B}")
    else:
        lines.append(f"  COUNT  {k[0]}:{k[1]} {k[2]} fn={k[3]} g={G} a={A} b={B}")
print(f"[{os.path.basename(W)}/{V}] keys={len(keys)} agreeB={agree} "
      f"FIXED={fixed} BROKE={broke} OVER(away)={over} UNDER(miss)={under}")
for l in lines:
    print(l)
