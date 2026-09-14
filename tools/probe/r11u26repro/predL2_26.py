#!/usr/bin/env python3
"""r11u26 L2 — the PRISTINE-DATABASE-keyed a-priori mover prediction.

THE FACE.  All three edits of this pass hang off ONE recorded fact, the
recognizer's `SrlgMemLeft::paramRead`: a const-function builder's body writes a
struct member from a WHOLE READ OF A NAME (`c.u = UU`).

  * the leftover clone (§ patParamLeftoverShare26) fires only in the drain arm
    guarded by `st.paramRead[i]`;
  * the flatten trigger (§ patParamEvalFuncRead26) asks
    `srlgEvalFuncMemberLeftovers` for exactly those `paramRead` entries;
  * the module assemble bail's exception reads `patOpVal`, which only the
    leftover clone ever sets.

So a database can move only if it holds a FUNCTION whose body carries an
`assignment` whose LHS is a `hier_path` and whose RHS is a bare `ref_obj`.
That is readable off the PRISTINE dump alone: function bodies are emitted in
every view, the LHS path is emitted as written, and a whole-name RHS is a
`ref_obj`.  The detector does NOT check that the read name is a PARAMETER, nor
that the function returns a packed struct, nor that a parameter calls it — it
is a deliberate SUPERSET, so a zero from it is a reading and not a silence.

    predL2_26.py <workdir-root> [...]      # walk *.uhdm under the workdirs
    predL2_26.py --dumps <dump> [...]      # already-dumped text (the control)

Every database is read; one that exceeds the dump budget is reported as ERR
and must be re-read with the budget lifted.
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
