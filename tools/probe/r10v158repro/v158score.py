#!/usr/bin/env python3
"""v158 VERIFIER scorer — INDEPENDENT of score158.py.

Difference that matters: the BLK KEY here is (owner, span) ONLY; the block's
KIND and NAME are part of the PAYLOAD.  score158.py puts KIND in the key, so a
begin -> named_begin move shows up as ONLY-A + a separate TOWARD and a
regression of that same shape could hide as ONLY-A + AWAY.  Here it cannot:
any kind/name change is scored against golden on the same key.

G = golden (Surelog, ALWAYS LHS), A = pristine, B = patched.
Payloads are SETS per key (multiset join, not a dict).
"""
import sys, collections

def load(p, want):
    m = collections.defaultdict(set)
    for ln in open(p):
        f = ln.rstrip("\n").split("\t")
        if len(f) < 3: continue
        rt = f[1]
        if rt == "BLK" and want == "BLK":
            if len(f) < 13: continue
            # key: owner, span     payload: kind, name, nvars, nstmts, nparam, varlist
            m[(f[5], f[6])].add((f[7], f[8], f[9], f[10], f[11], f[12]))
        elif rt in ("VAR","LOCAL","RET","PROP","FORMAL","MEMBER","PARAM","TPARAM") and want == "DECL":
            if len(f) < 14: continue
            m[(f[5], f[6], f[7])].add((f[8], f[9], f[10], f[11], f[12]))
    return m

def main():
    want = sys.argv[4] if len(sys.argv) > 4 else "BLK"
    g, a, b = load(sys.argv[1], want), load(sys.argv[2], want), load(sys.argv[3], want)
    n = collections.Counter()
    for k in sorted(set(g)|set(a)|set(b)):
        gv, av, bv = g.get(k,set()), a.get(k,set()), b.get(k,set())
        if not gv and not bv and av: n["ONLY-A"]+=1; print("ONLY-A\t%s\t%s"%(k,sorted(av))); continue
        if not gv and bv:
            tok = "AWAY" if not av else "ONLY-OURS"
            n[tok]+=1; print("%s\t%s\tA=%s B=%s"%(tok,k,sorted(av),sorted(bv))); continue
        if not av and not bv: n["ONLY-G"]+=1; print("ONLY-G\t%s\t%s"%(k,sorted(gv))); continue
        if av==gv and bv==gv: n["RIGHT"]+=1; continue
        if av!=gv and bv==gv: n["TOWARD"]+=1; print("TOWARD\t%s\n\tG=%s\n\tA=%s"%(k,sorted(gv),sorted(av))); continue
        if av==gv and bv!=gv: n["WRONG"]+=1; print("WRONG\t%s\n\tG=%s\n\tA=%s\n\tB=%s"%(k,sorted(gv),sorted(av),sorted(bv))); continue
        if av==bv: n["STILL"]+=1; print("STILL\t%s\n\tG=%s\n\tA=B=%s"%(k,sorted(gv),sorted(av))); continue
        # A!=G, B!=G, A!=B : did B get CLOSER or FARTHER?
        da = len(gv ^ av); db = len(gv ^ bv)
        tok = "RESHAPE-CLOSER" if db < da else ("RESHAPE-FARTHER" if db > da else "RESHAPE-SAME")
        n[tok]+=1; print("%s\t%s\n\tG=%s\n\tA=%s\n\tB=%s"%(tok,k,sorted(gv),sorted(av),sorted(bv)))
    print("-- rows=%s RIGHT=%d TOWARD=%d WRONG=%d STILL=%d RESHAPE-CLOSER=%d RESHAPE-SAME=%d RESHAPE-FARTHER=%d ONLY-G=%d AWAY=%d ONLY-OURS=%d ONLY-A=%d"
          % (want,n["RIGHT"],n["TOWARD"],n["WRONG"],n["STILL"],n["RESHAPE-CLOSER"],n["RESHAPE-SAME"],n["RESHAPE-FARTHER"],n["ONLY-G"],n["AWAY"],n["ONLY-OURS"],n["ONLY-A"]))
main()
