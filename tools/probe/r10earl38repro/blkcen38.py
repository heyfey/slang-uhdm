#!/usr/bin/env python3
"""r10earl38 — the GENERATE-BRANCH STATEMENT-LIST census.

For every `named_begin` / `begin` in a uhdm-dump, print a ONE-LINE signature of
its ORDERED vpiStmt list: each statement rendered as `kind@span[lhsname]`.

Why a purpose-built census instead of `diff`: the defect is a VECTOR-SIZE
mismatch (golden's branch has N statements, ours has N-2), so a line diff
shifts for the whole rest of the block and per-cell verdicts cannot be read off
it.  Keying on (view, branch fullname) gives one stable row per grid cell and
makes an ADDED / MISSING / REORDERED statement the first thing you see.

DEFAULT IS `-v all`, AND THAT IS A FIX, NOT A CONVENIENCE.  The obvious view
key — the last `|uhdmallModules:` / `|uhdmtopModules:` column-0 section marker
seen — is a LIE on a real design.  Earlgrey's dump carries **190**
`|uhdmallModules:` markers, **40** `|uhdmallPackages:`, **40**
`|uhdmtopPackages:` and **10** `|uhdmtopModules:`, interleaved: the dump
re-prints a section header for each chunk it walks, so a running two-state
`def`/`elab` machine mislabels huge regions.  Filtering on it SILENTLY DROPPED
2232 of 5553 blocks from this pass' first Earlgrey census — including
`work@ibex_cs_registers.g_pmp_registers`, which is a DEF-view block that the
machine had labelled `elab`.  The census is view-agnostic instead and the two
sides' row COUNTS are asserted equal (5553 = 5553) before any row is read; a
block that exists on one side only shows up as an unmatched row, which is
exactly the signal a view filter would have hidden.  `-v def` / `-v elab` are
kept for SINGLE-MODULE arms, where there is one marker of each and the key is
sound.

BACK-REFERENCE PRINTS ARE DROPPED: an object printed under a `|vpiParent:`
relation is a SECOND print of one object (it carries no children), not a second
block.  Counting them was the trap in the first reading of this pass' head.

Indent is used ONLY to find an object's own attributes and its children; it is
never part of the key (r10earl35 F5).

usage: blkcen38.py <dump> [-v all|def|elab] [-f FULLNAMEREGEX]
"""
import re
import sys

LINE_OBJ = re.compile(r'^(\s*)\\_([a-z_0-9]+): (.*)$')
LINE_REL = re.compile(r'^(\s*)\|(vpi[A-Za-z_]+):\s*$')
LINE_ATT = re.compile(r'^(\s*)\|(vpi[A-Za-z_]+|uhdm[a-zA-Z]+|[A-Z]+):(.*)$')
LINE_SEC = re.compile(r'^\|(uhdm[a-zA-Z]+):\s*$')
SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')
NAME = re.compile(r'\(([^()]*)\)(?:,|$)')

BLOCKS = ('named_begin', 'begin')


def objsig(rest):
    m = SPAN.search(rest)
    span = '%s:%s-%s:%s' % m.groups() if m else '-'
    ns = NAME.findall(rest)
    return (ns[-1] if ns else ''), span


def parse(path):
    """-> list of rows in file order.  Row kinds:
       ('SEC', name) | (indent,'OBJ',kind,name,span) |
       (indent,'REL',rel,'','') | (indent,'ATT',key,val,'')"""
    out = []
    with open(path, 'rt', errors='replace') as f:
        for ln in f:
            ln = ln.rstrip('\n')
            m = LINE_SEC.match(ln)
            if m:
                out.append((-1, 'SEC', m.group(1), '', ''))
                continue
            m = LINE_OBJ.match(ln)
            if m:
                nm, span = objsig(m.group(3))
                out.append((len(m.group(1)), 'OBJ', m.group(2), nm, span))
                continue
            m = LINE_REL.match(ln)
            if m:
                out.append((len(m.group(1)), 'REL', m.group(2), '', ''))
                continue
            m = LINE_ATT.match(ln)
            if m:
                out.append((len(m.group(1)), 'ATT', m.group(2), m.group(3), ''))
    return out


def first_name(rows, i):
    """The vpiName / Lhs-name of the object at rows[i], for readability."""
    ind = rows[i][0]
    j = i + 1
    rel = None
    lhs = ''
    own = ''
    while j < len(rows):
        r = rows[j]
        if r[0] == -1:
            break
        if r[0] <= ind:
            break
        if r[0] == ind + 2 and r[1] == 'ATT' and r[2] == 'vpiName' and not own:
            own = r[3]
        if r[0] == ind + 2 and r[1] == 'REL':
            rel = r[2]
        elif r[0] == ind + 2 and r[1] == 'OBJ' and rel == 'vpiLhs' and not lhs:
            lhs = r[3] or ''
            lhs = lhs.rsplit('.', 1)[-1]
        j += 1
    return own or lhs


def census(path, view_filter, name_re):
    rows = parse(path)
    view = '?'
    # A stack of (indent, is_backref) for the objects currently open, so a
    # subtree rooted at a |vpiParent: print can be skipped wholesale.
    out = []
    n = len(rows)
    for i in range(n):
        ind, k = rows[i][0], rows[i][1]
        if k == 'SEC':
            v = rows[i][2]
            if v == 'uhdmallModules':
                view = 'def'
            elif v == 'uhdmtopModules':
                view = 'elab'
            else:
                view = v
            continue
        if k != 'OBJ' or rows[i][2] not in BLOCKS:
            continue
        # BACK-REFERENCE: the immediately preceding REL at indent ind is the
        # relation this object hangs off.  vpiParent => a second print.
        rel = None
        for j in range(i - 1, -1, -1):
            if rows[j][0] == -1:
                break
            if rows[j][0] < ind:
                break
            if rows[j][0] == ind and rows[j][1] == 'REL':
                rel = rows[j][2]
                break
            if rows[j][0] == ind and rows[j][1] == 'OBJ':
                break
        if rel == 'vpiParent':
            continue
        if view_filter != 'all' and view != view_filter:
            continue
        full = rows[i][3]
        if name_re and not name_re.search(full):
            continue
        # Ordered vpiStmt children at indent ind+2.
        stmts = []
        crel = None
        j = i + 1
        while j < n:
            r = rows[j]
            if r[0] == -1 or r[0] <= ind:
                break
            if r[0] == ind + 2:
                if r[1] == 'REL':
                    crel = r[2]
                elif r[1] == 'OBJ':
                    if crel == 'vpiStmt':
                        nm = first_name(rows, j)
                        stmts.append('%s@%s[%s]' % (r[2], r[4], nm))
                    crel = None
            j += 1
        out.append('%-6s %-46s n=%-2d %s' %
                   (view, full, len(stmts), ' '.join(stmts)))
    return out


def main():
    args = sys.argv[1:]
    view = 'all'
    name_re = None
    path = None
    i = 0
    while i < len(args):
        if args[i] == '-v':
            view = args[i + 1]
            i += 2
        elif args[i] == '-f':
            name_re = re.compile(args[i + 1])
            i += 2
        else:
            path = args[i]
            i += 1
    if not path:
        sys.exit(__doc__)
    for ln in census(path, view, name_re):
        print(ln)


if __name__ == '__main__':
    main()
