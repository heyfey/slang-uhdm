#!/usr/bin/env python3
"""oppos.py <gold dump> <off dump> <on dump>: (r11u221) a POSITION-aware judge of § impPatCopyFirstListingUnparented215's
field: for every param_assign whose right side is an operation carrying a vpiTypespec, keyed by the enclosing instance /
package / module line and the operation's span, the ORDERED list of that ref's parent state (U = unparented, P =
parented, with its full name).  Golden lists more copies than ours in several shapes (a third listing), so a line
multiset reads a parent removed from ours as 'lost' even when the removed parent sits on golden's unparented first
copy; here the i-th copy of ours is compared with golden's i-th copy.  away = positions where OFF equals golden and ON
does not; toward = the reverse.  Reads uhdm-dump texts only (the caller dumps its own cases)."""
import sys, re, collections
def seqs(fn):
    L = open(fn, errors='replace').read().splitlines()
    cut = next((i for i, l in enumerate(L) if l.startswith('\\_weaklyReferenced')), len(L))
    out = collections.defaultdict(list); stack = []
    for i, l in enumerate(L[:cut]):
        ind = len(l) - len(l.lstrip()); s = l.strip()
        if re.match(r'\\_(module_inst|package|interface_inst|gen_scope|design):', s):
            while stack and stack[-1][0] >= ind: stack.pop()
            stack.append((ind, s.split(', file')[0].split(', line')[0]))
        if s.startswith('\\_operation:') and L[i-1].strip() == '|vpiRhs:':
            j = i + 1; ref = None
            while j < cut and (len(L[j]) - len(L[j].lstrip())) > ind:
                if L[j].strip() == '|vpiTypespec:' and (len(L[j]) - len(L[j].lstrip())) == ind + 2: ref = L[j+1].strip(); break
                j += 1
            if ref is None: continue
            ctx = ' > '.join(x[1] for x in stack if x[0] < ind)
            m = re.search(r'\((.*)\)', ref)
            out[(ctx, s)].append('P:' + m.group(1) if m else 'U')
    return out
G, O, N = (seqs(f) for f in sys.argv[1:4])
tow = away = same = 0; det = []
for k in sorted(set(O) | set(N)):
    g, o, n = G.get(k, []), O.get(k, []), N.get(k, [])
    for i in range(max(len(o), len(n))):
        gi = g[i] if i < len(g) else None; oi = o[i] if i < len(o) else None; ni = n[i] if i < len(n) else None
        if oi == ni: continue
        gs = gi[:1] if gi else None; os_ = oi[:1] if oi else None; ns = ni[:1] if ni else None   # U/P state
        if os_ == gs and ns != gs: away += 1; det.append(f'AWAY  {k[0][-60:]} | {k[1]} copy {i+1}: golden {gi} off {oi} on {ni}')
        elif ns == gs and os_ != gs: tow += 1; det.append(f'TOWARD {k[0][-60:]} | {k[1]} copy {i+1}: golden {gi} off {oi} on {ni}')
        else: same += 1; det.append(f'OTHER {k[0][-60:]} | {k[1]} copy {i+1}: golden {gi} off {oi} on {ni}')
print(f'parent-state positions: toward={tow} away={away} other={same}')
for d in det: print('  ' + d)
