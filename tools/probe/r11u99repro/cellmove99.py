#!/usr/bin/env python3
"""r11u99 PER-SLOT class-cell mover scorer.

The judge (`uhdm-cmp`) is BLIND to this pass's class faces: pass 96 already
recorded that the interface-emitted-as-module kind divergence MASKS them, and
closing the class face only UNMASKS that pre-existing divergence, so the cmp
line count RISES on an arm whose class listing became exactly right.  The
arbiter is therefore `classcell98.py`'s slot-keyed scorer, run on BOTH dump
pairs and differenced PER SLOT:

  MOVED-WRONG  a (holder, index) cell whose value equalled golden's on the
               PRISTINE pair and does not on the LAW pair -- including a cell
               that golden does not have at all and we minted (OURS-ONLY).
  AWAY         a (holder, class-name) subtree entry that matched on the
               pristine pair and stopped matching on the law pair.
  GAINED       the mirror of each, for the record.

usage: cellmove99.py <arm-dir> [<arm-dir> ...]
       each arm dir must hold gold.pris.dump ours.pris.dump
                              gold.lawx.dump ours.lawx.dump
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', 'r11u98repro'))
import classcell98  # noqa: E402


def slots(gold, ours):
    """(cells, subs) -- cells: {(holder, idx): (goldval, ourval)};
    subs: {(holder, name): (in_gold, in_ours)}."""
    g = classcell98.listings(gold)
    o = classcell98.listings(ours)
    cells, subs = {}, {}
    for h in set(g) | set(o):
        gv, ov = g.get(h, []), o.get(h, [])
        for i in range(max(len(gv), len(ov))):
            cells[(h, i)] = (gv[i] if i < len(gv) else None,
                             ov[i] if i < len(ov) else None)
        for n in set(gv) | set(ov):
            subs[(h, n)] = (n in gv, n in ov)
    return cells, subs


def main(dirs):
    mw = aw = gc = gs = 0
    rows = []
    for d in dirs:
        f = [os.path.join(d, x) for x in ('gold.pris.dump', 'ours.pris.dump',
                                          'gold.lawx.dump', 'ours.lawx.dump')]
        if not all(os.path.exists(x) for x in f):
            rows.append("  SKIP-NOFILE %s" % os.path.basename(d.rstrip('/')))
            continue
        cp, sp = slots(f[0], f[1])
        cq, sq = slots(f[2], f[3])
        a = os.path.basename(d.rstrip('/'))
        for k in set(cp) | set(cq):
            okp = k in cp and cp[k][0] is not None and cp[k][0] == cp[k][1]
            okq = k in cq and cq[k][0] is not None and cq[k][0] == cq[k][1]
            if okp and not okq:
                mw += 1
                rows.append("  MOVED-WRONG %s %s[%d] gold=%s ours=%s"
                            % (a, k[0], k[1],
                               cq.get(k, (None, None))[0],
                               cq.get(k, (None, None))[1]))
            elif okq and not okp:
                gc += 1
        for k in set(sp) | set(sq):
            okp = k in sp and sp[k][0] and sp[k][1]
            okq = k in sq and sq[k][0] and sq[k][1]
            if okp and not okq:
                aw += 1
                rows.append("  AWAY %s %s :: %s" % (a, k[0], k[1]))
            elif okq and not okp:
                gs += 1
    for r in rows:
        print(r)
    print("CELL MOVED-WRONG=%d CELL GAINED=%d SUB AWAY=%d SUB GAINED=%d "
          "(arms=%d)" % (mw, gc, aw, gs, len(dirs)))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
