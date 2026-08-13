#!/usr/bin/env python3
"""r10uvm71 -- THE task_func VECTOR CENSUS, per class_defn, ONE SIDE PER RUN.

  usage: ct71census.py <dump> [--class <fullname-substr>] [--newonly]

The head this pass owns is a VECTOR ENTRY:

    LHS: <null>                                       <- golden's vector ended
    RHS: function (uvm_pkg::uvm_objection::new) ...   <- ours carries one more

The standing rules are explicit that a MISSING or SURPLUS vector entry shifts
every later slot, so this census does NOT ask "is there a surplus at the end".
It lists the WHOLE vpiTaskFunc vector of every class_defn BY NAME, in ORDER, on
one side, so the two sides can be diffed slot for slot.

TRAPS ENCODED (each already paid for by this campaign):
  * uhdm-dump's FIRST LINE is the database path -> callers pass `sed 1d` dumps.
  * AN OBJECT IS NOT A DUMP OCCURRENCE.  A class_defn is printed once with its
    children and again, CHILDLESSLY, as a vpiParent back-reference (uvm_objection
    alone is printed 74 times in SimpleUVM).  A childless print has NO
    vpiTaskFunc children, so counting prints would report "no methods" for 73 of
    the 74.  Back-references are dropped and the remaining FULL prints are
    merged by (fullname, span) -- a class_defn is legitimately printed in full
    more than once (def view, elab view), and those prints must not be counted
    as two classes.
  * MERGING IS ASSERTED, NOT ASSUMED: if two full prints of the same class carry
    DIFFERENT task_func vectors, that is reported as VECTOR_DISAGREE rather than
    silently reduced to one of them -- a re-homed method would show up exactly
    there.
  * vpiTaskFunc entries are `function`/`task` objects; the ENTRY may itself be a
    back-reference print (the method's body lives elsewhere), so entries are
    keyed on NAME and never require children.
"""
import collections
import sys

sys.path.insert(0, __file__.rsplit('/', 1)[0])
from dumptree import parse, is_backref   # noqa: E402


def methods(cd):
    """The class_defn's vpiTaskFunc vector, in order, as (kind, name)."""
    out = []
    for fname, kid in cd.children:
        if fname in ('vpiMethod', 'vpiTaskFunc'):
            nm = kid.name or kid.fields.get('vpiName', '').strip()
            # the entry's fullname is what the dump parenthesises; keep the
            # LEAF so classes can be compared across differing prefixes.
            leaf = nm.rsplit('::', 1)[-1] if nm else '<anon>'
            out.append((kid.kind, leaf, nm, kid.span))
    return out


def main():
    path = sys.argv[1]
    want = None
    newonly = '--newonly' in sys.argv
    if '--class' in sys.argv:
        want = sys.argv[sys.argv.index('--class') + 1]

    _roots, nodes = parse(path)
    full = collections.OrderedDict()      # (name, span) -> list of vectors
    prints = collections.Counter()
    for n in nodes:
        if n.kind != 'class_defn':
            continue
        prints[n.name] += 1
        if is_backref(n):
            continue
        full.setdefault((n.name, n.span), []).append(methods(n))

    disagree = 0
    rows = []
    for (name, span), vecs in full.items():
        uniq = {tuple(v) for v in vecs}
        if len(uniq) > 1:
            disagree += 1
            print('VECTOR_DISAGREE %s @%s : %d distinct vectors across %d full '
                  'prints' % (name, span, len(uniq), len(vecs)))
            for v in uniq:
                print('   ', [e[1] for e in v])
        rows.append((name, span, vecs[0], len(vecs)))

    n_new = 0
    for name, span, vec, nprints in rows:
        names = [e[1] for e in vec]
        has_new = 'new' in names
        if has_new:
            n_new += 1
        if want and want not in name:
            continue
        if newonly and not has_new:
            continue
        print('CLASS %-58s @%-20s prints=%d n=%-3d new=%s' %
              (name, span, nprints, len(vec), 'YES' if has_new else 'no'))
        if want:
            for i, (kind, leaf, fn, sp) in enumerate(vec):
                print('   [%3d] %-9s %-40s @%s' % (i, kind, leaf, sp))

    print('-- class_defn OBJECTS (full prints merged): %d' % len(rows))
    print('-- class_defn with `new` in vpiTaskFunc:    %d' % n_new)
    print('-- VECTOR_DISAGREE: %d' % disagree)


if __name__ == '__main__':
    main()
