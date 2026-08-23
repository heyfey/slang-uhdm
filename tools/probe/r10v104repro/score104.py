#!/usr/bin/env python3
# Per-VALUE arm scorer: for each arm/view, classify every string cell as
# TO-GOLDEN (pristine wrong, patched right), AWAY (pristine right, patched
# wrong), STILL (both wrong the same way), REGRESS-NEW (a wrong value patched
# introduces that pristine never had).  Payload = the STRING:/vpiDecompile:
# text, which is what expr::Compare reads.  Multiset (Counter) join.
import sys, re, collections, os
def vals(p):
    c = collections.Counter()
    with open(p, errors='replace') as f:
        for ln in f:
            m = re.search(r'\|(STRING:|vpiDecompile:)(.*)$', ln.rstrip('\n'))
            if m: c[m.group(1)+m.group(2)] += 1
    return c
root = sys.argv[1]
bad = 0
for d in sorted(os.listdir(root)):
    dd = os.path.join(root, d)
    if not os.path.isdir(dd) or not os.path.exists(os.path.join(dd,'g.full')): continue
    g, p, q = vals(dd+'/g.full'), vals(dd+'/pris.full'), vals(dd+'/pat.full')
    excess_p = p - g   # wrong values pristine has
    excess_q = q - g   # wrong values patched has
    missing_p = g - p
    missing_q = g - q
    new_wrong = excess_q - excess_p     # AWAY: values patched invented
    new_miss  = missing_q - missing_p   # AWAY: golden values patched stopped producing
    fixed     = (excess_p - excess_q) + (missing_p - missing_q)
    tag = 'OK'
    if new_wrong or new_miss:
        tag = 'AWAY'; bad += 1
    print('%-30s %-10s TO-GOLDEN=%-4d AWAY=%-4d STILL=%d' % (d, tag, sum(fixed.values()), sum(new_wrong.values())+sum(new_miss.values()), sum((excess_q & excess_p).values())))
    for k,v in sorted(new_wrong.items()): print('        AWAY-NEW-WRONG  %r x%d' % (k,v))
    for k,v in sorted(new_miss.items()):  print('        AWAY-LOST-GOOD  %r x%d' % (k,v))
print('ARMS-WITH-AWAY', bad)
