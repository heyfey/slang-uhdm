#!/usr/bin/env python3
"""r11u28 L2 — the PRISTINE-DATABASE-keyed a-priori mover prediction.

THE FACE, and it is the SAME ONE r11u26 measured, because all three of this
pass's edits hang off the SAME recorded fact — the recognizer's
`SrlgMemLeft::paramRead`, set when a const-function builder's body writes a
struct member from a WHOLE READ OF A NAME (`c.u = UU`):

  * § patOpMemberAsmSplit28 (the `mw / n` render of an operation-valued
    member) asks `memLeftPatOpSrc28(lo[i].paramRead)` for every member and
    does nothing at all when that is null;
  * § catParamLeftoverReduce28 (the concat-valued parameter's reduced BIN
    leftover) lives INSIDE the drain arm guarded by `st.paramRead[i]`;
  * § patOpMemberSelSplit28 (the member read that slices the split bits)
    fires only when `patOpAsmBits28` is non-empty, and only the first edit
    ever writes to it.

No `paramRead`, no split, no reduce, no corrected reader.  So a database can
move only if it holds a FUNCTION whose body carries an `assignment` whose LHS
is a `hier_path` and whose RHS is a bare `ref_obj`.  That is readable off the
PRISTINE dump alone.  The detector does NOT check that the read name is a
PARAMETER, nor that the function returns a packed struct, nor that a parameter
calls it, nor that any member width fails to divide — it is a deliberate
SUPERSET, so a zero from it is a reading and not a silence.

    predL28.py <workdir-root> [...]      # walk *.uhdm under the workdirs
    predL28.py --dumps <dump> [...]      # already-dumped text (the control)

Every database is read; one that exceeds the dump budget is reported as ERR
and must be re-read with the budget lifted.  A golden-side `surelog.uhdm` left
in a verify_golden workdir is NAMED and COUNTED, never silently dropped.
"""
import os, re, subprocess, sys

UD = os.environ.get('UHDM_DUMP',
                    os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump'))
BUDGET = int(os.environ.get('L2_BUDGET', '1800'))
FUNC = re.compile(r'^(\s*)\\_(function|task): ')
ASG = re.compile(r'^(\s*)\\_assignment: ')
LHSP = re.compile(r'^\s*\\_hier_path: \(([^)]*)\)')
RHSR = re.compile(r'^\s*\\_ref_obj: \(([^)]*)\)')


def ind(s):
    return len(s) - len(s.lstrip(' '))


def scan_text(txt):
    """`<path> <- <name>` for every `assignment` standing inside a `function`
    (or `task`) block whose LHS is a hier_path and whose RHS is a ref_obj."""
    lines = txt.split('\n')
    hits = set()
    fstack = []          # indents of open function blocks
    astack = []          # indents of open assignment blocks
    cur = {}             # assignment indent -> [lhs, rhs]
    pend = None          # ('lhs'|'rhs', indent) just seen
    for l in lines:
        if not l.strip():
            continue
        i = ind(l)
        while fstack and i <= fstack[-1]:
            fstack.pop()
        while astack and i <= astack[-1]:
            a = astack.pop()
            v = cur.pop(a, None)
            if v and v[0] and v[1]:
                hits.add('%s<-%s' % (v[0], v[1]))
        if FUNC.match(l):
            fstack.append(i)
            continue
        if ASG.match(l):
            astack.append(i)
            cur[i] = [None, None]
            pend = None
            continue
        if fstack and astack:
            a = astack[-1]
            if l.strip() == '|vpiLhs:':
                pend = ('lhs', i)
                continue
            if l.strip() == '|vpiRhs:':
                pend = ('rhs', i)
                continue
            if pend is not None and i >= pend[1]:
                if pend[0] == 'lhs':
                    m = LHSP.match(l)
                    if m:
                        cur[a][0] = m.group(1)
                else:
                    m = RHSR.match(l)
                    if m:
                        cur[a][1] = m.group(1)
                pend = None
                continue
        pend = None
    for a in astack:
        v = cur.get(a)
        if v and v[0] and v[1]:
            hits.add('%s<-%s' % (v[0], v[1]))
    return hits


def scan_file(p):
    try:
        out = subprocess.run([UD, p], capture_output=True, text=True,
                             timeout=BUDGET)
    except Exception as e:
        return None, type(e).__name__
    return scan_text(out.stdout), None


def main(argv):
    if argv and argv[0] == '--dumps':
        for p in argv[1:]:
            hits = scan_text(open(p, errors='replace').read())
            print('%s  %s' % (p, ' '.join(sorted(hits)) if hits else '-'))
        return
    total = flagged = errs = skipped = 0
    # OUR binary writes `slang.uhdm` and nothing else.  A verify_golden workdir
    # also holds the GOLDEN side's `slpp_all/surelog.uhdm`, which this pass
    # cannot move by construction — and one of them (YosysOpenSparc/default) is
    # big enough to sit on the dump budget for minutes.  Those are COUNTED and
    # NAMED, never silently dropped: a census zero needs to say what it did not
    # read.
    ours = os.environ.get('L2_NAME', 'slang.uhdm')
    for root in argv:
        for dirpath, _d, files in os.walk(root):
            for f in sorted(files):
                if not f.endswith('.uhdm'):
                    continue
                if f != ours:
                    skipped += 1
                    print('SKIP-NOT-OURS %s' % os.path.join(dirpath, f),
                          flush=True)
                    continue
                p = os.path.join(dirpath, f)
                total += 1
                hits, err = scan_file(p)
                if err:
                    errs += 1
                    print('ERR %s %s' % (p, err), flush=True)
                    continue
                if hits:
                    flagged += 1
                    print('HIT %s  %s' % (p, ' '.join(sorted(hits)[:10])),
                          flush=True)
    print('L2 scanned=%d flagged=%d errors=%d skipped-not-ours=%d'
          % (total, flagged, errs, skipped))


if __name__ == '__main__':
    main(sys.argv[1:])
