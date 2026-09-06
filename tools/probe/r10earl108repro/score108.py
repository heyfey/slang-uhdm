#!/usr/bin/env python3
"""r10earl108 THE THREE-WAY SCORER -- MEASUREMENT ONLY.

  score108.py <cen.pris.txt> <cen.patch.txt> [label]

Both inputs are `cen108 ... --raw` outputs over the SAME golden.  Every row is
  <verdict>\tFORMAL=..\tKEY=..\tG=..\tO=..
LHS is ALWAYS golden; `G=` is golden's payload and `O=` is ours.

The scorer REFUSES to score two runs whose GOLDEN side differs on any key --
that would mean the two runs did not compare against the same database, and
every number below would be meaningless.

  TO_GOLDEN    pristine != golden, patched == golden          (the law working)
  AWAY_GOLDEN  pristine == golden, patched != golden          (MUST be 0)
  MOVED_WRONG  both wrong, and the patch CHANGED the answer   (MUST be 0)
  STILL_WRONG  both wrong, unchanged                          (a residue)
  SAME         both right
  ONLY-*       the key exists on one side only (reported, never scored -- the
               caller must ALSO check that the ONLY-* key SET is identical
               between the two runs, or a row that flipped INTO or OUT OF that
               bucket would be invisible)
"""
import sys
from collections import Counter


def load(path):
    rows = {}
    for line in open(path, 'rt', errors='replace'):
        if line.startswith('##') or '\t' not in line:
            continue
        parts = line.rstrip('\n').split('\t')
        if len(parts) < 5:
            continue
        verdict, formal, key, g, o = parts[0], parts[1], parts[2], parts[3], parts[4]
        # cenrun108 prefixes the WHOLE line with "<test> | ", so on a CORPUS run
        # the verdict column is "<test> | <verdict>".  Split it back out and put
        # the TEST in the key: without it two databases that share a parameter
        # fullname COLLIDE and a last-writer dict silently drops rows
        # (RESUME.md section 9's multiset-join trap).
        if ' | ' in verdict:
            test, verdict = verdict.rsplit(' | ', 1)
            key = test + '||' + key
        # STRIP the column tags before comparing: `G=<payload>` and
        # `O=<payload>` are equal only when the PAYLOADS are, and a first cut
        # that compared the tagged strings scored every row as different.
        if g.startswith('G='):
            g = g[2:]
        if o.startswith('O='):
            o = o[2:]
        rows[key] = (verdict, formal, g, o)
    return rows


def main(pris, patch, label=''):
    P, A = load(pris), load(patch)
    keys = set(P) | set(A)
    mismatch = [k for k in keys if k in P and k in A and P[k][2] != A[k][2]]
    if mismatch:
        print('REFUSED: the GOLDEN side differs on %d keys (e.g. %s)'
              % (len(mismatch), mismatch[0][:120]))
        return 3
    c = Counter()
    detail = []
    for k in sorted(keys):
        if k not in P or k not in A:
            c['ONLY_ONE_RUN'] += 1
            continue
        pv, pf, pg, po = P[k]
        av, af, ag, ao = A[k]
        if pv.startswith('ONLY') or av.startswith('ONLY'):
            c['ONLY_SIDED'] += 1
            continue
        pr_ok, at_ok = (pg == po), (ag == ao)
        if pr_ok and at_ok:
            c['SAME'] += 1
        elif not pr_ok and at_ok:
            c['TO_GOLDEN'] += 1
            detail.append(('TO_GOLDEN', af, k))
        elif pr_ok and not at_ok:
            c['AWAY_GOLDEN'] += 1
            detail.append(('AWAY_GOLDEN', af, k))
        elif po != ao:
            c['MOVED_WRONG'] += 1
            detail.append(('MOVED_WRONG', af, k))
        else:
            c['STILL_WRONG'] += 1
    print('%-22s TO_GOLDEN=%d AWAY_GOLDEN=%d MOVED_WRONG=%d STILL_WRONG=%d '
          'SAME=%d ONLY_SIDED=%d ONLY_ONE_RUN=%d'
          % (label, c['TO_GOLDEN'], c['AWAY_GOLDEN'], c['MOVED_WRONG'],
             c['STILL_WRONG'], c['SAME'], c['ONLY_SIDED'], c['ONLY_ONE_RUN']))
    for v, f, k in detail:
        print('   %-12s %-34s %s' % (v, f, k))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1], sys.argv[2],
                  sys.argv[3] if len(sys.argv) > 3 else ''))
