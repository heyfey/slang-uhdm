#!/usr/bin/env python3
"""r10buvm2 A-PRIORI MOVER PREDICTION, computed from the PRISTINE side ALONE.

    usage: predict2.py <pristine-workdir-root>            # scan every database
           predict2.py --dump <one-pristine.dump>         # scan one dump

THE RULE, fixed and written down BEFORE gate 5 was run, so it cannot be fitted
to the byte verifier's answer.  A database MOVES iff its PRISTINE dump holds a
CLASS PROPERTY (an object listed under `class_defn |vpiVariables:`) that has NO
`vpiExpr`, and whose SOURCE LINE writes one of the three initializer kinds this
pass newly models:

    (a) TIME LITERAL   `= 9200s` / `= 1.5ns` / ...   -> SS classPropTimeLitInit2
    (b) NULL           `= null`                      -> SS classPropNullInitParentedByTypespec2
    (c) SYSTEM CALL    `= $urandom` / `= $sqrt(..)`  -> SS classPropSysCallInit2

and a FOURTH, DELIBERATELY SEPARATE class:

    (d) MACRO-VALUED   `= `SOME_MACRO`

which this predictor CANNOT resolve (the macro body lives in an include this
script does not preprocess) and therefore reports as MAYBE.  uvm-1.2's
`time phase_timeout = `UVM_DEFAULT_TIMEOUT;` is exactly this cell, and a
predictor that ignored it would have declared SimpleUVM and Scoreboard
non-movers when they provably move.  Reporting it as a separate class makes the
prediction TWO-SIDED and falsifiable:

    CERTAIN  = (a) u (b) u (c)          the movers MUST include these
    MAYBE    = (d)                      the movers MUST be a subset of CERTAIN u MAYBE

WHY NOT grep THE `.uhdm` FILES: measured blind by pass 1 — a name is not a
contiguous byte string in the serialized capnp.  WHY NOT grep THE SOURCES
DIRECTLY: `= null` and `= $urandom` occur far more often in STATEMENT position
than in a class-property declaration, and this pass touches only the property
carrier; keying on the dump's own class-property listing is what keeps the two
apart.

GUARDS: a database that fails to dump counts as SCAN-FAIL and is NOT dropped
from the denominator; a source file that cannot be read counts as
UNREADABLE-SRC and is reported, never silently treated as "no initializer".
"""
import os
import re
import subprocess
import sys

OBJ = re.compile(r'^(?P<ind> *)\\_(?P<kind>[a-z_0-9]+): (?:\((?P<name>.*?)\))?,?(?P<rest>.*)$')
FLD = re.compile(r'^(?P<ind> *)\|(?P<f>[A-Za-z0-9_]+):(?P<v>.*)$')
LINE = re.compile(r'line:(\d+):(\d+)')
FILE = re.compile(r'file:([^,]+)')

TIME = re.compile(r'=\s*[0-9][0-9_]*(?:\.[0-9]+)?\s*(?:s|ms|us|ns|ps|fs)\s*[;,]')
NULLI = re.compile(r'=\s*null\s*[;,]')
SYSC = re.compile(r'=\s*\$[A-Za-z_][A-Za-z_0-9]*')
MACRO = re.compile(r'=\s*`[A-Za-z_][A-Za-z_0-9]*')

_src_cache = {}


def srcline(path, n):
    if path not in _src_cache:
        try:
            _src_cache[path] = open(path, encoding='utf-8',
                                    errors='replace').read().split('\n')
        except OSError:
            _src_cache[path] = None
    lines = _src_cache[path]
    if lines is None:
        return None
    return lines[n - 1] if 0 < n <= len(lines) else ''


def scan(dump_text):
    """-> (certain, maybe, unreadable) counts per kind for ONE dump."""
    stack = []            # (indent, kind, file)
    pending = None
    cur = None            # (indent, file, line, has_expr)
    seen = set()
    hits = {'time': 0, 'null': 0, 'sys': 0, 'macro': 0}
    unreadable = 0
    props = []
    for ln in dump_text.split('\n'):
        m = OBJ.match(ln)
        if m:
            ind = len(m.group('ind'))
            kind = m.group('kind')
            rest = m.group('rest')
            fm = FILE.search(rest)
            lm = LINE.search(rest)
            while stack and stack[0 if False else -1][0] >= ind:
                stack.pop()
            ownerkind = stack[-1][1] if stack else None
            ownerfile = stack[-1][2] if stack else None
            myfile = fm.group(1) if fm else ownerfile
            ownerfield = pending
            stack.append((ind, kind, myfile))
            pending = None
            if cur is not None and ind <= cur[0]:
                props.append(cur)
                cur = None
            if ownerkind == 'class_defn' and ownerfield == 'vpiVariables' and lm:
                cur = [ind, myfile, int(lm.group(1)), False, m.group('name') or '']
            elif cur is not None and ind == cur[0] + 2 and ownerfield == 'vpiExpr':
                cur[3] = True
            continue
        f = FLD.match(ln)
        if f:
            pending = f.group('f') if f.group('v') == '' else None
            continue
        pending = None
    if cur is not None:
        props.append(cur)
    for ind, path, line, has_expr, name in props:
        if has_expr or not path:
            continue
        key = (path, line, name)
        if key in seen:
            continue
        seen.add(key)
        t = srcline(path, line)
        if t is None:
            unreadable += 1
            continue
        if TIME.search(t):
            hits['time'] += 1
        elif NULLI.search(t):
            hits['null'] += 1
        elif SYSC.search(t):
            hits['sys'] += 1
        elif MACRO.search(t):
            hits['macro'] += 1
    return hits, unreadable


def report(tag, hits, unreadable):
    certain = hits['time'] + hits['null'] + hits['sys']
    maybe = hits['macro']
    if certain or maybe or unreadable:
        print("PREDICT %-46s time=%d null=%d sys=%d | macro=%d | unreadable=%d"
              % (tag, hits['time'], hits['null'], hits['sys'], hits['macro'],
                 unreadable))
    return certain, maybe


def main():
    D = os.environ.get('UHDM_DUMP',
                       os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump'))
    if len(sys.argv) >= 3 and sys.argv[1] == '--dump':
        txt = open(sys.argv[2], encoding='utf-8', errors='replace').read()
        h, u = scan(txt)
        report(sys.argv[2], h, u)
        return
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    root = sys.argv[1]
    if not os.path.isdir(root):
        print("FATAL: no workdir %s" % root)
        sys.exit(3)
    if not os.access(D, os.X_OK):
        print("FATAL: no uhdm-dump at %s" % D)
        sys.exit(3)
    paths = []
    for dp, _dn, fn in os.walk(root):
        if 'slang.uhdm' in fn:
            paths.append(os.path.join(dp, 'slang.uhdm'))
    paths.sort()
    tot = scanfail = 0
    ncert = nmaybe = 0
    certain_names, maybe_names = [], []
    for p in paths:
        tot += 1
        try:
            txt = subprocess.run([D, p], capture_output=True, text=True,
                                 timeout=600).stdout
        except Exception:
            txt = ''
        if not txt.strip():
            print("SCAN-FAIL %s" % os.path.relpath(p, root))
            scanfail += 1
            continue
        h, u = scan(txt)
        tag = os.path.relpath(os.path.dirname(p), root)
        c, m = report(tag, h, u)
        if c:
            ncert += 1
            certain_names.append(tag)
        elif m:
            nmaybe += 1
            maybe_names.append(tag)
    print("SCANNED: %d databases  SCAN-FAIL: %d" % (tot, scanfail))
    print("PREDICTED MOVERS (CERTAIN): %d" % ncert)
    for n in certain_names:
        print("   C %s" % n)
    print("PREDICTED MOVERS (MAYBE, macro-valued init only): %d" % nmaybe)
    for n in maybe_names:
        print("   M %s" % n)


if __name__ == '__main__':
    main()
