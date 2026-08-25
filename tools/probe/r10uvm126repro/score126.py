#!/usr/bin/env python3
"""r10uvm126 - GOLDEN-vs-OURS element-typespec scorer.

Reads two cen126 outputs (LHS is ALWAYS golden) and joins the CELL rows as a
MULTISET on (owner kind, owner name, owner span).  For every joined key it
compares the ELEMENT TYPESPEC's kind and name and classifies the cell:

  AGREE        identical kind+name
  LAW          golden's element ts is an ANONYMOUS BUILTIN KEYWORD typespec
               (one of the eleven compileBuiltinTypespec/chandle/event classes,
               VpiName empty) and ours differs   <- the population this pass owns
  RESIDUE      golden's element ts is NAMED (a typedef/enum/struct/class object)
               or is <null> and ours differs     <- explicitly out of law
  ONLY-GOLDEN / ONLY-OURS   unmatched keys

With a third file (the PATCHED census) every LAW/RESIDUE cell is additionally
scored TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG / MOVED-WRONG.
MEASUREMENT ONLY - the official uhdm-cmp is the judge.
   usage: score126.py <golden.cen> <ours.cen> [patched.cen] [--cells]
"""
import sys, collections

KEYWORD = {"string_typespec","real_typespec","short_real_typespec",
           "chandle_typespec","event_typespec","byte_typespec",
           "short_int_typespec","int_typespec","long_int_typespec",
           "integer_typespec","time_typespec"}

def load(path):
    d = collections.defaultdict(list)
    for L in open(path, errors="replace"):
        p = L.rstrip("\n").split("\t")
        if p[0] != "CELL" or len(p) < 5:
            continue
        ow = p[2].split("|")
        key = (ow[0], ow[1], ow[2])
        ep = p[4].split("|")
        kind = ep[0]
        name = ep[1] if len(ep) > 1 else ""
        sgn  = p[3]                      # array-ts kind|span|nr|idx
        reg  = p[5] if len(p) > 5 else "-"
        d[key].append((kind, name, sgn.split("|")[0], reg))
    return d

def summarise(g, o, q=None, cells=False):
    keys = sorted(set(g) | set(o))
    cnt = collections.Counter()
    bykind = collections.Counter()
    rows = []
    for k in keys:
        gl, ol = sorted(g.get(k, [])), sorted(o.get(k, []))
        if not gl:
            cnt["ONLY-OURS"] += len(ol); continue
        if not ol:
            cnt["ONLY-GOLDEN"] += len(gl); continue
        n = max(len(gl), len(ol))
        for i in range(n):
            gv = gl[i] if i < len(gl) else None
            ov = ol[i] if i < len(ol) else None
            if gv is None: cnt["ONLY-OURS"] += 1; continue
            if ov is None: cnt["ONLY-GOLDEN"] += 1; continue
            same = gv[0] == ov[0] and gv[1] == ov[1]
            if same:
                cnt["AGREE"] += 1; continue
            law = gv[0] in KEYWORD and gv[1] == ""
            cls = "LAW" if law else "RESIDUE"
            cnt[cls] += 1
            bykind[(cls, gv[0], ov[0])] += 1
            verdict = ""
            if q is not None:
                ql = sorted(q.get(k, []))
                qv = ql[i] if i < len(ql) else None
                if qv is None: verdict = "GONE"
                elif qv[0] == gv[0] and qv[1] == gv[1]: verdict = "TO-GOLDEN"
                elif qv == ov: verdict = "STILL-WRONG"
                else: verdict = "MOVED-WRONG"
                cnt[cls + ":" + verdict] += 1
            rows.append((cls, k, gv, ov, verdict))
    if q is not None:
        for k in sorted(set(q) - set(o)):
            cnt["PATCH-ONLY-KEY"] += len(q[k])
        # cells that AGREED before must still agree
        for k in sorted(set(g) & set(o) & set(q)):
            gl, ol, ql = sorted(g[k]), sorted(o[k]), sorted(q[k])
            for i in range(min(len(gl), len(ol), len(ql))):
                if gl[i][0] == ol[i][0] and gl[i][1] == ol[i][1] and ql[i] != ol[i]:
                    cnt["BROKE-AGREEING"] += 1
                    rows.append(("BROKE", k, gl[i], ol[i], str(ql[i])))
    for c, n in sorted(cnt.items()):
        print("%-24s %d" % (c, n))
    for (cls, gk, ok), n in sorted(bykind.items()):
        print("KINDPAIR %-8s golden=%-22s ours=%-22s %d" % (cls, gk, ok, n))
    if cells:
        for cls, k, gv, ov, v in rows:
            print("CELL %-8s %-28s %-14s golden=%-24s ours=%-24s %s" %
                  (cls, k[1], k[2], gv[0] + ("(" + gv[1] + ")" if gv[1] else ""),
                   ov[0] + ("(" + ov[1] + ")" if ov[1] else ""), v))
    return cnt

if __name__ == "__main__":
    a = [x for x in sys.argv[1:] if not x.startswith("--")]
    cells = "--cells" in sys.argv
    g = load(a[0]); o = load(a[1])
    q = load(a[2]) if len(a) > 2 else None
    summarise(g, o, q, cells)
