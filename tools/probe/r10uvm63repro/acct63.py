#!/usr/bin/env python3
"""r10uvm63 MOVER ACCOUNTING — every INDEX-slot typespec in a real corpus
database, on all three sides, with its `vpiSigned` state.

    usage: acct63.py <g.dump> <p.dump> <q.dump>
             g = golden (Surelog), p = pristine ours, q = patched ours

WHY IT EXISTS.  The corpus census counts index typespecs by KIND, because our
own pre-patch dump cannot tell `[int]` from `[int unsigned]`.  The mover count
is therefore a SUBSET of the candidates, and a pass that reports "5 moved" out
of "7 candidates" without naming the 2 that did not has not measured anything —
it has rounded.  This lists all of them, keyed by (kind, span), so each
non-mover is named and explained rather than absorbed into a total.

It reuses ct63cells.py's descent rule verbatim: the index typespec prints as a
BARE HEADER under `vpiActual`, so its fields are read at the top-level typespec
LISTING.  LHS is ALWAYS golden.

**IT DOES NOT USE `fullest()`, AND THAT IS A CORRECTION MADE MID-PASS.**  A
first version of this script read each span's FULLEST listing occurrence, the
rule ct63cells.py uses on the arms.  On a real UVM database that rule is WRONG,
and it was caught because its total disagreed with the dump diff: it reported
4 moved objects where `diff P.dump Q.dump` showed 5 added lines.  The cause is a
SAME-SPAN COLLISION — uvm_sequence_base.svh:144 `[int]` has TWO distinct
typespec objects at the identical span (the def view and the elab view), one of
which was ALREADY signed by another producer.  Picking one occurrence silently
merged the pair and hid a genuine mover.  This version therefore reports the
signed-state of EVERY listing occurrence as a VECTOR, e.g. `[1,-] -> [1,1]`, so
a collision is visible instead of resolved.  The arms keep one declaration per
line precisely so this cannot happen there.
"""
import sys

sys.path.insert(0, __file__.rsplit('/', 1)[0])
from ct63cells import parse, collect_index_ts, children, fields_of  # noqa: E402


def occ_states(rows, header_text):
    """Signed-state of EVERY occurrence of `header_text` that has own children,
    in dump order.  A bare back-reference (no children) is not an occurrence
    that can carry fields and is skipped, not counted as absent."""
    st = []
    for i, (_ind, k, text) in enumerate(rows):
        if k != 'O' or text != header_text:
            continue
        kids = children(rows, i)
        if not kids:
            continue
        f = fields_of(rows, i)
        st.append('1' if f.get('vpiSigned') == '1' else '-')
    return st or ['-NOFIELDS-']


def side(path):
    rows = parse(path)
    out = {}
    for (slot, tk, span, hdr) in collect_index_ts(rows):
        out[(slot, tk, span)] = ','.join(occ_states(rows, hdr))
    return out


def main():
    if len(sys.argv) != 4:
        print(__doc__)
        return 2
    G, P, Q = (side(a) for a in sys.argv[1:4])
    keys = sorted(set(G) | set(P) | set(Q))
    print(f'{"SLOT":<6}{"KIND":<20}{"SPAN":<18}'
          f'{"GOLDEN":<10}{"PRISTINE":<10}{"PATCHED":<10}VERDICT')
    moved = held = nogold = 0
    for k in keys:
        g, p, q = G.get(k, '-NOOBJ-'), P.get(k, '-NOOBJ-'), Q.get(k, '-NOOBJ-')
        # count of occurrences that gained the flag, per (kind,span)
        gained = q.count('1') - p.count('1') if p != '-NOOBJ-' != q else 0
        if gained:
            v = f'MOVED x{gained}' + ('  (now matches golden)' if q == g
                                      else f'  (golden says {g})')
            moved += gained
        elif '1' in g and q.count('1') < g.count('1'):
            v = 'HELD BACK -- golden signs an occurrence we still do not'
            held += 1
        else:
            v = 'unchanged'
            if g == '-NOOBJ-':
                nogold += 1
        print(f'{k[0]:<6}{k[1]:<20}{k[2]:<18}{g:<10}{p:<10}{q:<10}{v}')
    print(f'-- index-slot (kind,span) keys={len(keys)}  OCCURRENCES MOVED='
          f'{moved}  HELD-BACK={held}  (golden has no object there: {nogold})')
    print('   OCCURRENCES MOVED must equal the ADDED line count mv63.sh '
          'reports for the same database.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
