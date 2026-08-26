#!/usr/bin/env python3
"""r10earl98 -- CENSUS SCORER (multiset join, golden vs a candidate).

LHS is ALWAYS golden.  Reads two `ct98cen` outputs (`count \t KEY \t PAYLOAD`)
and scores over the KEY universe:

  BOTH-SAME    key present both sides, same payload
  MOVED-WRONG  key present both sides, payloads differ
  GOLDEN-ONLY  key only in golden
  OURS-ONLY    key only in ours

Multiset join: rows are (key, payload, count); a key may legitimately repeat
with different payloads, so counts are joined per (key,payload) and the
per-key surplus is reported, never dropped by a last-writer dict.

  usage: score98.py <golden.cen> <cand.cen> [--detail]
"""
import sys, collections

def load(p):
    m = collections.defaultdict(collections.Counter)   # key -> {payload: count}
    keys = collections.Counter()
    for line in open(p):
        line = line.rstrip("\n")
        if not line: continue
        c, rest = line.split("\t", 1)
        key, pay = rest.rsplit("\t", 1)
        m[key][pay] += int(c)
        keys[key] += int(c)
    return m, keys

def main():
    g, gk = load(sys.argv[1])
    o, ok = load(sys.argv[2])
    detail = "--detail" in sys.argv[3:]
    both_same = moved = 0
    gonly = oonly = 0
    det = []
    for k in set(gk) | set(ok):
        if k in gk and k in ok:
            gp = g[k]
            op = o[k]
            same = 0
            for p in set(gp) & set(op):
                same += min(gp[p], op[p])
            tot = max(gk[k], ok[k])
            both_same += same
            moved += tot - same
            if detail and tot - same:
                det.append("MOVED-WRONG %s golden=%s ours=%s" % (k, gp, op))
        elif k in gk:
            gonly += gk[k]
            if detail: det.append("GOLDEN-ONLY %s %s" % (k, list(g[k])))
        else:
            oonly += ok[k]
            if detail: det.append("OURS-ONLY %s %s" % (k, list(o[k])))
    print("BOTH-SAME %d MOVED-WRONG %d GOLDEN-ONLY %d OURS-ONLY %d" %
          (both_same, moved, gonly, oonly))
    for d in sorted(det): print("  " + d)

main()
