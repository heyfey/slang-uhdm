#!/usr/bin/env python3
"""r10buvm29 corpus census JOIN.  MEASUREMENT ONLY -- uhdm-cmp is the judge.

Multiset-joins golden against ours per cell on (line, OP, owner) -- keys
COLLIDE (a DEF and an ELAB clone share one), so a last-writer dict silently
drops rows (buvm22's trap).  Spans are a READING column only: no generated
`Compare` reads VpiFile/VpiLineNo/VpiColumnNo.

Columns:
  DBS-WITH-STREAM   databases whose GOLDEN holds a stream operation
  CASTOVERSTREAM    golden cast operations whose sole operand is a stream
                    -- THE LAW'S POPULATION, i.e. the whole predicted mover set
  MISSING-CAST      such a cast that OURS does not have  (the defect)
  BARE-STREAM       golden streams whose parent is NOT a cast (THE FENCE)
  FALSE-CAST        a cast over a stream OURS has and golden does not
                    (a patch that over-fires lights this up)

usage: join29.py <censusdir> [--verbose]
"""
import sys, os, re
from collections import Counter, defaultdict

d = sys.argv[1]
verbose = "--verbose" in sys.argv

def load(p):
    out = []
    for ln in open(p):
        f = ln.rstrip("\n").split("\t")
        if len(f) >= 7:
            out.append(f[:7])
    return out

tot = Counter()
per_db = defaultdict(Counter)
for fn in sorted(os.listdir(d)):
    if not fn.endswith(".g"):
        continue
    key = fn[:-2]
    gp, op = os.path.join(d, fn), os.path.join(d, key + ".o")
    if not os.path.exists(op):
        continue
    G, O = load(gp), load(op)
    # a cast whose SOLE operand is a stream operation (op<71>/op<72>)
    def castsOverStream(rows):
        return [r for r in rows
                if r[1] == "CAST" and r[3] == "1"
                and re.fullmatch(r"operation<7[12]>", r[4])]
    def streams(rows):
        return [r for r in rows if r[1].startswith("STREAM")]
    gc, oc = castsOverStream(G), castsOverStream(O)
    gs, os_ = streams(G), streams(O)
    c = per_db[key]
    if gs:
        c["DBS-WITH-STREAM"] = 1
    c["CASTOVERSTREAM"] = len(gc)
    c["BARE-STREAM"] = len([r for r in gs if r[5] != "operation<67>"])
    # match on (line, owner) -- the span differs by design (R-STREAMSPAN)
    gk = Counter((r[0].split(":")[0], r[6]) for r in gc)
    ok = Counter((r[0].split(":")[0], r[6]) for r in oc)
    c["MISSING-CAST"] = sum((gk - ok).values())
    c["FALSE-CAST"] = sum((ok - gk).values())
    for k, v in c.items():
        tot[k] += v

print("databases joined:", len([k for k in per_db]))
for k in ("DBS-WITH-STREAM", "CASTOVERSTREAM", "MISSING-CAST", "FALSE-CAST",
          "BARE-STREAM"):
    print(f"  {k:16s} {tot[k]}")
print("-- databases with a golden CAST-OVER-STREAM (the predicted mover set):")
for k in sorted(per_db):
    if per_db[k]["CASTOVERSTREAM"]:
        print(f"   {k}  casts={per_db[k]['CASTOVERSTREAM']} "
              f"missing={per_db[k]['MISSING-CAST']} "
              f"false={per_db[k]['FALSE-CAST']}")
if verbose:
    print("-- databases with any golden stream:")
    for k in sorted(per_db):
        if per_db[k]["DBS-WITH-STREAM"]:
            print(f"   {k}  bare={per_db[k]['BARE-STREAM']}")
