#!/usr/bin/env python3
"""r11u98 CELL + SUBTREE scorer for the class listing and the class homes.

r11u95's `subtree95.py` scores vpiProcess / vpiTaskFunc / vpiClassDefn entries
keyed by (kind, name, span) — which is BLIND to this pass, because every cell
this pass moves has the SAME key set on both binaries and differs only in
POSITION, or sits under a holder `subtree95.py` never opens (the design root's
`uhdmallClasses`).  So this scorer is keyed differently:

  CELL   one (holder, index) slot of a class listing.  The holder is the
         dump's `class_defn` owner path — `<home fullname>|vpiClassDefn` for a
         module/program/package and `<design>|uhdmallClasses` for the design
         root — and the cell VALUE is the class's own name.  Scored PER CELL:
         a listing golden writes as [A, Z] and we write as [Z, A] is TWO wrong
         cells, not one wrong listing.  This is the only scorer that can see
         LAW A at all.
  SUBTREE one class_defn NAME under one holder, order-blind.  This is what
         sees LAW B: a class that is absent from our database entirely, or
         published under the wrong holder.

Both are scored against the GOLDEN dump, per arm, and summed.  MOVED-WRONG is
a cell that matched golden on the FIRST dump pair and does not on the second;
AWAY is a subtree entry that matched and stopped matching.

usage: classcell98.py <gold.dump> <ours.dump> [--rows]
"""
import re
import sys

CLS = re.compile(r'^(\s*)\\_class_defn: \(([^)]*)\)')
HOLDER = re.compile(r'^(\s*)\|(vpiClassDefn|uhdmallClasses):\s*$')


def listings(path):
    """{holder_key: [class fullname, ...]} — every class_defn vector in the
    dump, in the order the dump prints it.  The holder key is the nearest
    enclosing `|vpiClassDefn:` / `|uhdmallClasses:` marker plus the indent, so
    two different homes never collide and a NESTED class (which Surelog puts
    in its own vector) is a holder of its own."""
    out = {}
    lines = open(path, errors='replace').read().splitlines()
    # the owner of a marker is the last object line at a SMALLER indent
    owner_stack = []   # (indent, text)
    cur = None
    for ln in lines:
        m = re.match(r'^(\s*)\\_([a-z_]+): (.*)$', ln)
        if m:
            ind = len(m.group(1))
            while owner_stack and owner_stack[-1][0] >= ind:
                owner_stack.pop()
            cm = CLS.match(ln)
            if cm and cur is not None and cm.start(1) is not None:
                if len(cm.group(1)) == cur[1]:
                    out.setdefault(cur[0], []).append(cm.group(2))
            owner_stack.append((ind, re.sub(r', id:\d+', '',
                                            m.group(2) + ':' + m.group(3))))
            continue
        hm = HOLDER.match(ln)
        if hm:
            ind = len(hm.group(1))
            own = 'ROOT'
            for i, t in reversed(owner_stack):
                if i < ind:
                    own = t
                    break
            cur = ('%s|%s' % (own, hm.group(2)), ind)
    return out


def score(gold, ours):
    g, o = listings(gold), listings(ours)
    cells_ok = cells_bad = cells_gold_only = cells_ours_only = 0
    sub_match = sub_gold = sub_ours = 0
    rows = []
    for h in sorted(set(g) | set(o)):
        gl, ol = g.get(h, []), o.get(h, [])
        for i in range(max(len(gl), len(ol))):
            gv = gl[i] if i < len(gl) else None
            ov = ol[i] if i < len(ol) else None
            if gv is None:
                cells_ours_only += 1
                rows.append('CELL-OURS-ONLY %s[%d]=%s' % (h, i, ov))
            elif ov is None:
                cells_gold_only += 1
                rows.append('CELL-GOLD-ONLY %s[%d]=%s' % (h, i, gv))
            elif gv == ov:
                cells_ok += 1
            else:
                cells_bad += 1
                rows.append('CELL-DIFF %s[%d] gold=%s ours=%s' % (h, i, gv, ov))
        gs, os_ = set(gl), set(ol)
        sub_match += len(gs & os_)
        sub_gold += len(gs - os_)
        sub_ours += len(os_ - gs)
        for k in sorted(gs - os_):
            rows.append('SUB-GOLD-ONLY %s %s' % (h, k))
        for k in sorted(os_ - gs):
            rows.append('SUB-OURS-ONLY %s %s' % (h, k))
    return dict(CELL_OK=cells_ok, CELL_DIFF=cells_bad,
                CELL_GOLD_ONLY=cells_gold_only, CELL_OURS_ONLY=cells_ours_only,
                SUB_MATCH=sub_match, SUB_GOLD_ONLY=sub_gold,
                SUB_OURS_ONLY=sub_ours), rows


if __name__ == '__main__':
    st, rows = score(sys.argv[1], sys.argv[2])
    print(' '.join('%s=%d' % kv for kv in st.items()))
    if '--rows' in sys.argv:
        for r in rows:
            print('   ' + r)
