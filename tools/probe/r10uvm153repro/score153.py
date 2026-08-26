#!/usr/bin/env python3
"""r10uvm153 — THE ARM SCORER.  MEASUREMENT ONLY; the judge is uhdm-cmp.

Reads two `ct153bind` reports of the SAME golden — one against the PRISTINE
database, one against the PATCHED one — and classifies every key that is not
identical on both sides of golden in each report:

    WRONG->RIGHT   the key disagreed with golden pristine and agrees patched
    RIGHT->WRONG   the key agreed pristine and disagrees patched   (must be 0)
    AWAY           the key disagreed both times AND the patched disagreement is
                   a binding we ADDED where golden has none        (must be 0)
    STILL-WRONG    disagreed both times, unchanged
    CHANGED-WRONG  disagreed both times, differently (each one is printed)

A key ABSENT from a report is a key that AGREED there (ct153bind prints only
GOLD-BOUND / OURS-BOUND / DIFF rows unless --all), so absence means RIGHT.
usage: score153.py <pris.bind.txt> <pat.bind.txt>
"""
import sys, re

def load(path):
    rows = {}
    for ln in open(path):
        m = re.match(r'^(GOLD-BOUND|OURS-BOUND|DIFF|ONLY-GOLD|ONLY-OURS)\s+(\S+)\s+(.*)$', ln.rstrip('\n'))
        if not m:
            continue
        rows[m.group(2)] = (m.group(1), m.group(3).strip())
    return rows

def main():
    a, b = load(sys.argv[1]), load(sys.argv[2])
    keys = sorted(set(a) | set(b))
    w2r = r2w = away = still = chg = 0
    for k in keys:
        pa, pb = a.get(k), b.get(k)
        if pa and not pb:
            w2r += 1; print("WRONG->RIGHT  %s  was %s" % (k, pa[0]))
        elif pb and not pa:
            r2w += 1
            print("RIGHT->WRONG  %s  now %s %s" % (k, pb[0], pb[1]))
        elif pa == pb:
            still += 1
        else:
            # both wrong, differently.  An OURS-BOUND that was not OURS-BOUND
            # before is a binding this pass ADDED where golden has none: AWAY.
            if pb[0] == 'OURS-BOUND' and pa[0] != 'OURS-BOUND':
                away += 1; print("AWAY          %s  %s -> %s %s" % (k, pa[0], pb[0], pb[1]))
            else:
                chg += 1; print("CHANGED-WRONG %s  %s -> %s %s" % (k, pa[0], pb[0], pb[1]))
    print("-- WRONG->RIGHT=%d RIGHT->WRONG=%d AWAY=%d STILL-WRONG=%d CHANGED-WRONG=%d"
          % (w2r, r2w, away, still, chg))
    return 0

sys.exit(main())
