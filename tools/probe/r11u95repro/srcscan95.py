#!/usr/bin/env python3
"""r11u95 SOURCE-LEVEL census: which corpus tests can each face reach?

Every face this pass lands is scoped to a PROGRAM home, so all three questions
are syntactic properties of a `program ... endprogram` body and a scanner can
answer them without building a database:

  LAWA  -- a program whose body contains a GENERATE construct AND, inside it,
           one of the member kinds this pass re-homes (initial / final /
           task / function / class).  Reported per kind.
  LAWB  -- a program whose body contains a LOOP generate (`for (genvar ...)`),
           the only shape § caGenLoopZeroIterStillWritten95 can reach.
  LAWC  -- a program whose body declares a TASK or a FUNCTION at all: the
           population of § caProgTaskFuncInstIsElab95, which is WIDER than the
           other two because it needs no generate construct.

A CENSUS ZERO NEEDS A POSITIVE CONTROL: run the same scanner, unchanged, over
this pass's own grid, where every count must be nonzero.

  usage: srcscan95.py <dir> [<dir> ...]
"""
import os, re, sys

def strip(t):
    t = re.sub(r'/\*.*?\*/', ' ', t, flags=re.S)
    t = re.sub(r'//[^\n]*', ' ', t)
    t = re.sub(r'"(\\.|[^"\\])*"', ' ', t)
    return t

PROG = re.compile(r'\bprogram\b(.*?)\bendprogram\b', re.S)
GEN  = re.compile(r'\bgenerate\b')
LOOP = re.compile(r'\bfor\s*\(\s*genvar\b')
KIND = {
    'initial':  re.compile(r'\binitial\b'),
    'final':    re.compile(r'\bfinal\b'),
    'task':     re.compile(r'\btask\b'),
    'function': re.compile(r'\bfunction\b'),
    'class':    re.compile(r'\bclass\b'),
}

def genspans(body):
    """The text inside each `generate ... endgenerate` region, plus the text of
    every `if`/`for`/`case` generate written without the keywords (which the
    scanner approximates by the whole body when `generate` is absent but a
    genvar loop is present)."""
    out = []
    for m in re.finditer(r'\bgenerate\b(.*?)\bendgenerate\b', body, re.S):
        out.append(m.group(1))
    return out

def scan(path):
    try:
        t = strip(open(path, encoding='utf-8', errors='replace').read())
    except OSError:
        return {}
    hits = {}
    for i, m in enumerate(PROG.finditer(t)):
        body = m.group(1)
        tag = '%s@%d' % (os.path.basename(path), t[:m.start()].count('\n') + 1)
        r = {}
        if GEN.search(body):
            r['gen'] = 1
            for g in genspans(body):
                for k, rx in KIND.items():
                    if rx.search(g):
                        r['LAWA.' + k] = r.get('LAWA.' + k, 0) + 1
        if LOOP.search(body):
            r['LAWB'] = 1
        if KIND['task'].search(body) or KIND['function'].search(body):
            r['LAWC'] = 1
        if r:
            hits[tag] = r
    return hits

def walk(root):
    tot, files = {}, 0
    nprog = 0
    for dp, _, fns in os.walk(root):
        for fn in fns:
            if not fn.endswith(('.v', '.sv', '.svh', '.vh')):
                continue
            p = os.path.join(dp, fn)
            h = scan(p)
            if not h:
                continue
            files += 1
            for tag, r in h.items():
                nprog += 1
                print('%s\t%s\t%s' % (os.path.relpath(p, root), tag,
                                      ' '.join('%s=%d' % kv for kv in sorted(r.items()))))
                for k, v in r.items():
                    tot[k] = tot.get(k, 0) + v
    return files, nprog, tot

if __name__ == '__main__':
    for root in sys.argv[1:]:
        files, nprog, tot = walk(root)
        print('# %s: files_with_hits=%d programs_with_hits=%d %s' %
              (root, files, nprog,
               ' '.join('%s=%d' % kv for kv in sorted(tot.items())) or 'NOTHING'))
