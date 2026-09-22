#!/usr/bin/env python3
"""v11u93 verifier source census — WIDER than srcscan95.py on purpose.

srcscan95.py only looks inside `generate ... endgenerate` regions, so a BARE
conditional generate in a program (`if (1) begin ... end`, no keywords — the
x22_progbaregen shape, which the law DOES reach) is invisible to it.  This
scanner flags a program body that holds ANY of: the `generate` keyword, a
genvar loop, a bare `if (`/`case (` at body level, or a task/function/class
declaration.  Over-approximates on purpose; the emitter trace decides.
"""
import os, re, sys
def strip(t):
    t = re.sub(r'/\*.*?\*/', ' ', t, flags=re.S)
    t = re.sub(r'//[^\n]*', ' ', t)
    t = re.sub(r'"(\\.|[^"\\])*"', ' ', t)
    return t
PROG = re.compile(r'\bprogram\b(.*?)\bendprogram\b', re.S)
TESTS = {
    'gen_kw':   re.compile(r'\bgenerate\b'),
    'genvar':   re.compile(r'\bgenvar\b'),
    'bare_if':  re.compile(r'\bif\s*\('),
    'bare_case':re.compile(r'\bcase\s*\('),
    'taskfunc': re.compile(r'\b(task|function)\b'),
    'class':    re.compile(r'\bclass\b'),
    'initial':  re.compile(r'\binitial\b'),
    'final':    re.compile(r'\bfinal\b'),
}
tot = {k: 0 for k in TESTS}
progs = 0
rows = []
for root in sys.argv[1:]:
    for dp, dn, fn in os.walk(root):
        for f in fn:
            if not f.endswith(('.v', '.sv', '.svh', '.vh')):
                continue
            p = os.path.join(dp, f)
            try:
                t = strip(open(p, encoding='utf-8', errors='replace').read())
            except OSError:
                continue
            for m in PROG.finditer(t):
                progs += 1
                body = m.group(1)
                hit = [k for k, rx in TESTS.items() if rx.search(body)]
                for k in hit:
                    tot[k] += 1
                if hit:
                    rows.append('%s  %s' % (os.path.relpath(p, root), ','.join(sorted(hit))))
print('PROGRAMS=%d' % progs)
for k in sorted(tot):
    print('  %-10s %d' % (k, tot[k]))
for r in sorted(rows):
    print('   HIT %s' % r)
