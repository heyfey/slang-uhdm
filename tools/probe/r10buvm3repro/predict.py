#!/usr/bin/env python3
"""r10buvm3 — CORPUS-WIDE PREDICTION for § aggMemberAggTdSharesListing3.

The law fires on: a member of an aggregate typedef declared INSIDE A CLASS
whose written type names a struct/union typedef that has a listing typespec.

This is a SOURCE-TEXT predictor, deliberately conservative in one direction and
loose in the other, and it says so:
  * it finds `class ... endclass` spans, then `typedef struct|union { ... }` INSIDE
    them, then member lines whose leading type identifier is a name declared by
    a `typedef struct|union ... <name>;` ANYWHERE in the same file set;
  * it does NOT resolve imports, so a member typed by a typedef from ANOTHER
    file is MISSED (under-count), and it does not elaborate, so a shape that
    never reaches the emitter is COUNTED (over-count).
It is a prediction to be falsified by the byte verifier, not a measurement.

  usage: predict.py <root> [<root> ...]
"""
import os, re, sys, collections

# `[^;]*?` was the first spelling and it is WRONG: a struct body is FULL of
# semicolons, so it could never reach the closing brace and the whole scan
# reported ZERO member-cells on a corpus that provably has them (UVM).  A
# predictor that reads clean because its regex cannot match is the worst kind
# of instrument.
TD = re.compile(r'\btypedef\s+(?:struct|union)\b.*?\}\s*(\w+)\s*(?:\[[^\]]*\]\s*)*;', re.S)
CLS = re.compile(r'^\s*(?:virtual\s+)?class\b', re.M)
ENDCLS = re.compile(r'^\s*endclass\b', re.M)
INNER = re.compile(r'\btypedef\s+(?:struct|union)\b[^{;]*\{(.*?)\}\s*(\w+)\s*;', re.S)

def files(root):
    for d, _, fs in os.walk(root):
        for f in fs:
            if f.endswith(('.sv', '.svh', '.v', '.vh')):
                yield os.path.join(d, f)

hits = collections.Counter()
detail = []
for root in sys.argv[1:]:
    for p in files(root):
        try:
            t = open(p, errors='ignore').read()
        except OSError:
            continue
        names = set(TD.findall(t))
        if not names:
            continue
        # class spans
        spans = []
        starts = [m.start() for m in CLS.finditer(t)]
        ends = [m.end() for m in ENDCLS.finditer(t)]
        for s in starts:
            e = next((x for x in ends if x > s), None)
            if e:
                spans.append((s, e))
        for s, e in spans:
            body = t[s:e]
            for mbody, mname in INNER.findall(body):
                for line in mbody.split(';'):
                    m = re.match(r'\s*(?:rand\s+|randc\s+)?(\w+)\s+\w+\s*$', line)
                    if m and m.group(1) in names:
                        hits[p] += 1
                        detail.append((p, mname, m.group(1), line.strip()))
for p, n in hits.most_common():
    print(f'{n:4}  {p}')
print(f'-- files={len(hits)} member-cells={sum(hits.values())}')
for d in detail[:40]:
    print('   ', d[1], '::', d[3])
