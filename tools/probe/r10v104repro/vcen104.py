#!/usr/bin/env python3
"""r10v104 verifier census - PER-SLOT TO-GOLDEN / AWAY / STILL.
Key = (owner kind, owner span, dump depth, field); payload = the value TEXT,
which is Compare-visible (expr::Compare reads VpiDecompile; STRING is the
dump-side twin).  Multiset per key (Counter, never a dict).  The classification
is done PER KEY against golden, so a slot that was RIGHT in pristine and is
WRONG after the patch is reported as AWAY even when the total counts balance.
  usage: vcen104.py <golden.dump> <pristine.dump> <patched.dump>
"""
import re, sys
from collections import Counter
OWNER = re.compile(r'^(\s*)\\_(\w+):(.*?)(?:, id:\d+)?(, line:\d+:\d+, endln:\d+:\d+)?\s*$')
VAL   = re.compile(r'^(\s*)\|(STRING|vpiDecompile):(.*)$')
def cells(path):
    out, stack = [], []
    for ln in open(path, errors='replace'):
        ln = ln.rstrip('\n'); m = OWNER.match(ln)
        if m:
            ind = len(m.group(1))
            while stack and stack[-1][0] >= ind: stack.pop()
            stack.append((ind, m.group(2), (m.group(4) or '').strip())); continue
        m = VAL.match(ln)
        if not m: continue
        ind = len(m.group(1))
        owner = next(((k,s) for (i,k,s) in reversed(stack) if i < ind), ('?','?'))
        out.append(((owner[0], owner[1], ind, m.group(2)), m.group(3)))
    return out
def bykey(p):
    d = {}
    for k,v in p: d.setdefault(k, Counter())[v]+=1
    return d
g,p,q = (bykey(cells(x)) for x in sys.argv[1:4])
to_g=away=still=same=0; away_ex=[]
for k in set(g)|set(p)|set(q):
    G,P,Q = g.get(k,Counter()), p.get(k,Counter()), q.get(k,Counter())
    # per key: how many payloads matched golden before vs after
    mp = sum((G&P).values()); mq = sum((G&Q).values())
    if mq > mp: to_g += mq-mp
    elif mq < mp:
        away += mp-mq
        if len(away_ex) < 12: away_ex.append((k, sorted(G.items()), sorted(P.items()), sorted(Q.items())))
    else: same += mq
    still += sum((G-Q).values())
print("TO-GOLDEN=%d AWAY=%d STILL-WRONG=%d UNCHANGED-MATCHED=%d" % (to_g, away, still, same))
for e in away_ex: print("   AWAY", e)
