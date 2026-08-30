#!/usr/bin/env python3
# r10earl101 -- MEASUREMENT ONLY.  The per-key MULTISET scorer for ct101cen.
#
#   reg101.py <golden.rows> <ours.rows> [<ours2.rows> ...]
#
# KEY   = view, owner kind, owner fullname, site, signal, field path
# VALUE = the COMPARE-VISIBLE payload (kind | VpiName | vpiInstance kind+name |
#         span).  The FILE is stripped: our databases carry an empty VpiFile on
# some objects (RESUME s9) and no generated Compare reads VpiFile.
#
# Joined as a MULTISET per key (keys collide -- a last-writer dict drops rows).
# Reports BOTH one-sided sets explicitly, so an AWAY-GOLDEN move (a bare name
# where golden is qualified, or an alias where golden has none) is scored, not
# hidden.
import sys, collections

def load(p):
    m = collections.Counter()
    with open(p) as f:
        for ln in f:
            ln = ln.rstrip('\n')
            if not ln.startswith('SIG\t'):
                continue
            parts = ln.split('\t')
            if len(parts) != 8:
                continue
            _, view, okind, ofull, site, sig, path, payload = parts
            # strip the file basename from the payload's last field
            bits = payload.split('|')
            if len(bits) == 4:
                sp = bits[3]
                sp = sp[sp.rfind(':', 0, sp.find('-') if '-' in sp else len(sp)):] if False else sp.split(':', 1)[1] if ':' in sp else sp
                bits[3] = sp
                payload = '|'.join(bits)
            m[(view, okind, ofull, site, sig, path, payload)] += 1
    return m

def score(g, o, tag):
    both = g & o
    gonly = g - o
    oonly = o - g
    print(f"[{tag}] BOTH-SAME {sum(both.values())}  GOLDEN-ONLY {sum(gonly.values())}  OURS-ONLY {sum(oonly.values())}")
    # a MOVED cell = a key present on both sides with a different payload
    gk = collections.Counter()
    ok = collections.Counter()
    for k, c in gonly.items():
        gk[k[:6]] += c
    for k, c in oonly.items():
        ok[k[:6]] += c
    moved = sum((gk & ok).values())
    print(f"[{tag}] MOVED (same key, different payload) {moved}   "
          f"GOLDEN-ONLY-KEYS {sum((gk - ok).values())}  OURS-ONLY-KEYS {sum((ok - gk).values())}")
    return gonly, oonly, gk, ok

if __name__ == '__main__':
    g = load(sys.argv[1])
    for p in sys.argv[2:]:
        o = load(p)
        gonly, oonly, gk, ok = score(g, o, p.split('/')[-1])
        shared = gk & ok
        rows = []
        for k, c in gonly.items():
            if k[:6] in shared:
                rows.append(('G', c, k))
        for k, c in oonly.items():
            if k[:6] in shared:
                rows.append(('O', c, k))
        rows.sort(key=lambda r: (r[2][:6], r[0]))
        for side, c, k in rows:
            print(f"  {side}-ONLY x{c} " + ' | '.join(k))
