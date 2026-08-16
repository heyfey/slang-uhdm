#!/usr/bin/env python3
"""r10uvm77 — PREDICT THE MOVERS, from the PRISTINE ARTIFACTS ALONE.

Run this BEFORE byteverify.sh, on the PRISTINE workdirs, so the expected answer
is written down before the measurement.

THE PREDICATE IS NEARLY AN IFF, AND THE ONE PLACE IT IS NOT IS NAMED.
§ classMethodParensLessStepIsRefObj77 rewrites exactly one thing: the TRAILING
element of a dotted `hier_path` our emitter built for a method call, when the
call was written WITHOUT parentheses.  In the PRISTINE artifact that element is
a `method_func_call`, and the parens-less form has a signature the artifact
carries all by itself:

  * our pristine sets the hier_path's span to `expr.sourceRange`, which for the
    parens-ful form runs through the closing `)` and for the parens-less form
    stops at the end of the method name.  So
        hier_path END == trailing method_func_call END
    is TRUE for the parens-less form and FALSE for every parens-ful one
    (`q.size()` differs by the two written parens; an argument list by more).

  * the element must carry NO `vpiArgument`: the code's own
    `call.arguments().size() == 1` clause, read off the artifact.

  * a `this`-ROOTED path is FENCED OUT of the law and is excluded here too.

  * the r10svs2 SYSTEM-call spelling (`data.size`) already emits a `ref_obj` in
    the pristine build, so it carries no `method_func_call` and cannot be
    counted twice.

WHERE IT IS NOT AN IFF, NAMED RATHER THAN HIDDEN:

  * EMPTY PARENS ARE INVISIBLE IN THE ARTIFACT.  `(cntxt.get_depth())` is
    written with parentheses, carries no argument, and our pristine hier_path
    ends exactly where its `method_func_call` ends — it looks identical to the
    parens-less form in the database and is flagged here.  Only the CODE, which
    reads the `(` out of the source buffer, can tell them apart.  SimpleUVM has
    23 such cells against 3 real ones, so this predicate is roughly 9x loose on
    UVM and says so.
  * the artifact cannot see WHITESPACE either: `q . size` is parens-less and the
    code's `anchorOk77` guard deliberately refuses it (r10svs2's F2 residue).

So the predicate is an UPPER BOUND: a flagged database that does not move is
EXPECTED; a mover OUTSIDE the prediction is a FINDING, never a rounding error.

  usage: ct77predict.py <pristine verify_golden workdir> [--jobs N]

GUARDS: a database uhdm-dump cannot read is counted as DUMP_FAIL and printed;
a workdir with zero databases exits 6 rather than printing a clean zero.
"""
import concurrent.futures
import os
import re
import subprocess
import sys

DUMP = os.environ.get('UHDM_DUMP',
                      os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump'))
HDR = re.compile(r'^(\s*)\\_(\w+): \(([^)]*)\)'
                 r'(?:, line:(\d+):(\d+), endln:(\d+):(\d+))?')


def scan(path):
    """-> (path, candidate parens-less trailing steps, err)."""
    try:
        p = subprocess.run([DUMP, path], capture_output=True, text=True,
                           errors='replace', timeout=1800)
    except Exception as e:
        return (path, -1, str(e))
    if p.returncode != 0 and not p.stdout:
        return (path, -1, 'dump rc=%d' % p.returncode)
    lines = p.stdout.splitlines()
    n = len(lines)
    hits = set()
    for i, ln in enumerate(lines):
        m = HDR.match(ln)
        if not m or m.group(2) != 'hier_path' or not m.group(4):
            continue
        ind, hpname, hpend = m.group(1), m.group(3), m.group(6) + ':' + m.group(7)
        if hpname.split('.', 1)[0] == 'this':
            continue
        childind = len(ind) + 2
        last = None
        lastind = 0
        label = None
        j = i + 1
        while j < n:
            s = lines[j]
            if not s.strip():
                break
            cur = len(s) - len(s.lstrip())
            if cur <= len(ind):
                break
            body = s.lstrip()
            if cur == childind and body.startswith('|'):
                label = body
            elif cur == childind and body.startswith('\\_') and label == '|vpiActual:':
                c = HDR.match(s)
                if c:
                    last = (c.group(2),
                            (c.group(6) + ':' + c.group(7)) if c.group(6) else '-',
                            (c.group(4) + ':' + c.group(5)) if c.group(4) else '-')
                    lastind = cur
                    lastat = j
            j += 1
        if not (last and last[0] == 'method_func_call' and last[1] == hpend):
            continue
        # the element's OWN child depth only: a written argument list is
        # parentheses by definition and is the code's own args-size clause.
        hasarg = False
        k = lastat + 1
        while k < n:
            t = lines[k]
            if not t.strip():
                break
            cu = len(t) - len(t.lstrip())
            if cu <= lastind:
                break
            if cu == lastind + 2 and t.lstrip().startswith('|vpiArgument:'):
                hasarg = True
                break
            k += 1
        if not hasarg:
            hits.add((hpname, last[2]))
    return (path, len(hits), '')


def main():
    root = sys.argv[1]
    jobs = 2
    if '--jobs' in sys.argv:
        jobs = int(sys.argv[sys.argv.index('--jobs') + 1])
    paths = []
    for dp, _, fns in os.walk(root):
        for f in fns:
            if f == 'slang.uhdm':
                paths.append(os.path.join(dp, f))
    paths.sort()
    if not paths:
        print('NO_DATABASES under', root)
        sys.exit(6)
    flagged = fails = 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as ex:
        for path, k, err in ex.map(scan, paths):
            rel = os.path.relpath(os.path.dirname(path), root)
            if k < 0:
                print('DUMP_FAIL %-50s %s' % (rel, err))
                fails += 1
            elif k:
                print('PREDICT_MOVE %-50s parensLessSteps=%d' % (rel, k))
                flagged += 1
    print('-- databases=%d  PREDICT_MOVE=%d  DUMP_FAIL=%d' %
          (len(paths), flagged, fails))


main()
