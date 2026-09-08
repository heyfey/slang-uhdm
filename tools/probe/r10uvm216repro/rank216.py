#!/usr/bin/env python3
"""r10uvm216 — THE SHIFT-IMMUNE ORDER SCORER.  MEASUREMENT ONLY.

WHY IT EXISTS.  The `POS|` census family keys on the ABSOLUTE index, so one
entry that only golden holds shifts every later index and reads as N moved
cells even when the relative order is identical.  Grid arm F is exactly that:
golden hoists an out-of-body class-method definition (`f216_cls::get`) into the
interface listing and we do not — a PRE-EXISTING residue of a different family —
so an absolute-index census cannot say whether this pass's reordering moved the
arm toward golden or away from it.

This scorer removes the shift.  Per holder it takes the entries whose PAYLOAD
both sides hold (the multiset intersection), ranks each side's copy among ONLY
those common entries, and compares the ranks.  A row here means the two sides
genuinely disagree about the ORDER of entries they both have.

  RANK-BOTH   <n>  <holder>|rank=<r>|<payload>   same payload at the same
                                                 common-rank on both sides
  RANK-GOLDEN <n>  ...                           golden's rank, unmatched
  RANK-OURS   <n>  ...                           ours, unmatched

usage: rank216.py <golden.kc> <ours.kc> [--only-diff]
"""
import sys
from collections import Counter, defaultdict


def load_pos(path):
    """holder -> [payload, ...] in index order."""
    rows = defaultdict(list)
    with open(path) as f:
        for line in f:
            line = line.rstrip("\n")
            if not line:
                continue
            _, _, key = line.partition("\t")
            if not key.startswith("POS|"):
                continue
            parts = key.split("|")
            if len(parts) < 3:
                continue
            holder = parts[1]
            if parts[2] == "NULLVEC":
                continue
            if not parts[2].startswith("idx="):
                continue
            idx = int(parts[2][4:])
            payload = "|".join(parts[3:])
            rows[holder].append((idx, payload))
    for h in rows:
        rows[h].sort()
    return rows


def ranked(seq, common):
    """rank each entry among ONLY the entries whose payload is in `common`."""
    out = []
    left = Counter(common)
    r = 0
    for _, p in seq:
        if left[p] > 0:
            left[p] -= 1
            out.append((r, p))
            r += 1
    return out


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    g = load_pos(sys.argv[1])
    o = load_pos(sys.argv[2])
    only_diff = "--only-diff" in sys.argv[3:]
    both = og = oo = 0
    rows = []
    for h in sorted(set(g) | set(o)):
        gs, os_ = g.get(h, []), o.get(h, [])
        gc, oc = Counter(p for _, p in gs), Counter(p for _, p in os_)
        common = Counter()
        for p in set(gc) & set(oc):
            common[p] = min(gc[p], oc[p])
        gr = Counter(f"{h}|rank={r:05d}|{p}" for r, p in ranked(gs, common))
        orr = Counter(f"{h}|rank={r:05d}|{p}" for r, p in ranked(os_, common))
        for k in sorted(set(gr) | set(orr)):
            gn, on = gr.get(k, 0), orr.get(k, 0)
            c = min(gn, on)
            if c and not only_diff:
                rows.append(("RANK-BOTH", c, k))
            both += c
            if gn > on:
                rows.append(("RANK-GOLDEN", gn - on, k))
                og += gn - on
            elif on > gn:
                rows.append(("RANK-OURS", on - gn, k))
                oo += on - gn
    for tag, n, k in rows:
        print(f"{tag}\t{n}\t{k}")
    print(f"-- RANK-BOTH={both} RANK-GOLDEN={og} RANK-OURS={oo}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
