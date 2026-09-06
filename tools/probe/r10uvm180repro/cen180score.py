#!/usr/bin/env python3
"""r10uvm180 — score two ct180cen runs (golden-vs-pristine, golden-vs-patched).

ct180cen prints one line per cell:
    <STATUS><spaces><key>   gold=<v>  ours=<v>     (DIFFER)
    <STATUS><spaces><key>   <v>                     (AGREE)
    <STATUS><spaces><key>   gold=<v> / ours=<v>     (ONLY-GOLDEN / ONLY-OURS)

This joins the two runs ON THE KEY and reports the four verdicts a landing is
scored on.  ONLY-* rows are key gaps, never movements: counting one as a
movement is how a NODEDUP census manufactures AWAY-GOLDEN phantoms
(RESUME.md §9), so they are reported separately and never scored.

usage: cen180score.py <cen.pristine.txt> <cen.patched.txt> [label]
"""
import re
import sys

ROW = re.compile(r"^(AGREE|DIFFER|ONLY-GOLDEN|ONLY-OURS)\s+(.*)\s{3,}(\S.*)$")


def load(path):
    st, val = {}, {}
    with open(path) as f:
        for line in f:
            m = ROW.match(line.rstrip("\n"))
            if not m:
                continue
            status, key, rest = m.group(1), m.group(2).rstrip(), m.group(3)
            st[key] = status
            ours = None
            i = rest.find("ours=")
            if i >= 0:
                ours = rest[i + 5:].strip()
            elif status == "AGREE":
                ours = rest.strip()
            val[key] = ours
    return st, val


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    sa, va = load(sys.argv[1])
    sb, vb = load(sys.argv[2])
    label = sys.argv[3] if len(sys.argv) > 3 else "row"
    keys = set(sa) | set(sb)
    togold = away = movedwrong = stillwrong = agreeboth = gaps = 0
    for k in sorted(keys):
        a, b = sa.get(k), sb.get(k)
        if a is None or b is None or a.startswith("ONLY") or b.startswith("ONLY"):
            gaps += 1
            continue
        if a == "AGREE" and b == "AGREE":
            agreeboth += 1
        elif a == "DIFFER" and b == "AGREE":
            togold += 1
            print("TOGOLD      %s  was=%s" % (k, va.get(k)))
        elif a == "AGREE" and b == "DIFFER":
            away += 1
            print("AWAY        %s  now=%s" % (k, vb.get(k)))
        elif va.get(k) != vb.get(k):
            movedwrong += 1
            print("MOVED-WRONG %s  was=%s  now=%s" % (k, va.get(k), vb.get(k)))
        else:
            stillwrong += 1
            print("STILL-WRONG %s  both=%s" % (k, va.get(k)))
    print("CENSCORE %s TOGOLD=%d AWAY=%d MOVED-WRONG=%d STILL-WRONG=%d "
          "AGREE-BOTH=%d KEY-GAPS=%d cells=%d"
          % (label, togold, away, movedwrong, stillwrong, agreeboth, gaps,
             len(keys)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
