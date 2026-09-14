#!/usr/bin/env python3
"""r11u24 L2 — the PRISTINE-DATABASE-keyed a-priori mover prediction.

The law changes ONE recognizer, `srlgEvalFuncMemberLeftovers`, which today
REJECTS every const function whose body writes BELOW the first level of the
struct it returns.  A database can therefore only move if it holds a FUNCTION
whose body carries an `assignment` whose LHS is a `hier_path` naming THREE OR
MORE elements (`c.u.a`).  That is readable off the PRISTINE dump alone — the
function bodies are emitted in every view, and the LHS path is emitted as
written, so a database without such a write CANNOT move.

    predL2_24.py <workdir-root> [...]      # walk *.uhdm under the workdirs
    predL2_24.py --dumps <dump> [...]      # already-dumped text (the control)

Prints one HIT line per flagged database and a final census line.  Every
database is read; one that exceeds the dump budget is reported as ERR and must
be re-read with the budget lifted — a silent skip would make the census a
guess.
"""
import os, re, subprocess, sys

UD = os.environ.get('UHDM_DUMP',
                    os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump'))
BUDGET = int(os.environ.get('L2_BUDGET', '1800'))
FUNC = re.compile(r'^(\s*)\\_(function|task): ')
ASG = re.compile(r'^(\s*)\\_assignment: ')
LHSP = re.compile(r'^\s*\\_hier_path: \(([^)]*)\)')


def ind(s):
    return len(s) - len(s.lstrip(' '))


def scan_text(txt):
    """Names of >=3-element hier_paths that are the LHS of an `assignment`
    standing inside a `function` (or `task`) block."""
    lines = txt.split('\n')
    hits = set()
    fstack = []          # indents of open function blocks
    astack = []          # (indent, in_lhs) of open assignment blocks
    pend = None          # indent of a `|vpiLhs:` just seen inside an assignment
    for l in lines:
        if not l.strip():
            continue
        i = ind(l)
        while fstack and i <= fstack[-1]:
            fstack.pop()
        while astack and i <= astack[-1]:
            astack.pop()
        if FUNC.match(l):
            fstack.append(i)
            continue
        if ASG.match(l):
            astack.append(i)
            pend = None
            continue
        if fstack and astack:
            if l.strip() == '|vpiLhs:':
                pend = i
                continue
            if pend is not None and i >= pend:
                m = LHSP.match(l)
                if m and m.group(1).count('.') >= 2:
                    hits.add(m.group(1))
                pend = None
                continue
        pend = None
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
    total = flagged = errs = 0
    for root in argv:
        for dirpath, _d, files in os.walk(root):
            for f in sorted(files):
                if not f.endswith('.uhdm'):
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
    print('L2 scanned=%d flagged=%d errors=%d' % (total, flagged, errs))


if __name__ == '__main__':
    main(sys.argv[1:])
