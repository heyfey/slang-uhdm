#!/usr/bin/env python3
"""r10uvm65 — THE CENSUS-PREDICT, run BEFORE the byte verifier.

Finds, in SOURCE, every site § emptyFnBodyEndLabelBegin65 can fire on: a
FUNCTION whose prototype's `;` is followed immediately by `endfunction : <label>`
with nothing in between.  Comments and strings are stripped first, so a
commented-out body cannot masquerade as an empty one.

  usage: census65.py <root> [<root> ...]

Prints one line per FILE with hits (count + the labels) and a per-DIRECTORY
total, so a corpus-wide "which tests can move" prediction is a grep away.

WHY A SOURCE SCAN AND NOT A DUMP SCAN: predicting from the patched binary's own
output is not a prediction, it is the measurement restated.  The prediction has
to be independent of the patch, and the four terms of the law are all syntactic.

TERMS ENCODED (each is an arm cell, see README):
  * the end label is REQUIRED  -> `end(function|task)\\s*:` with a name.
  * the body must be EMPTY     -> nothing but whitespace between `;` and the
                                  `end(function|task)`.
  * `new` is excluded          -> a constructor prototype is skipped by name.
  * a TASK also needs a NON-EMPTY tf_port_list; a FUNCTION never does.  This is
    the term the FIRST version of this script got wrong: it had no task arm at
    all, on the strength of eight golden-bare task cells that all happened to
    be written `task foo();`.  golden's `task uvm_reg_block::readmemh(string
    filename); endtask: readmemh` HAS the block.
UNDER-COUNT, STATED: a source scan cannot see which files a given test actually
compiles, nor how many VIEWS (def / elab / package clone) each function is
emitted in, so the per-test figure is a LOWER BOUND on dump-line movers and an
EXACT bound on distinct SUBROUTINES.
"""
import os
import re
import sys

# `function`/`task` ... `;` `end...` `:` name — with the `;` and the `end`
# keyword adjacent.  DOTALL: the prototype legitimately spans lines (do_open
# spans 3).  The two keywords are matched as ONE alternation and cross-checked,
# so `function ... endtask` cannot count.
PAT = re.compile(
    r'\b(?P<kw>function|task)\b(?P<proto>[^;{}]*?);\s*end(?P<endkw>function|task)'
    r'\s*:\s*(?P<lbl>[A-Za-z_]\w*)',
    re.DOTALL)
PORTS = re.compile(r'\(\s*\)')
LINECOMMENT = re.compile(r'//[^\n]*')
BLOCKCOMMENT = re.compile(r'/\*.*?\*/', re.DOTALL)
STRLIT = re.compile(r'"(\\.|[^"\\\n])*"')


def strip(text):
    text = BLOCKCOMMENT.sub(lambda m: '\n' * m.group(0).count('\n'), text)
    text = LINECOMMENT.sub('', text)
    text = STRLIT.sub('""', text)
    return text


def scan(path):
    try:
        raw = open(path, errors='replace').read()
    except OSError:
        return []
    out = []
    for m in PAT.finditer(strip(raw)):
        lbl = m.group('lbl')
        proto = m.group('proto')
        if m.group('kw') != m.group('endkw'):
            continue                         # `function ... endtask` is nothing
        if lbl == 'new':                     # the constructor is excluded
            continue
        if 'extern' in proto or 'pure' in proto:
            continue                         # a prototype has no body to empty
        if m.group('kw') == 'task':
            # a TASK needs a NON-EMPTY tf_port_list: `task t();` and `task t;`
            # are both golden-bare (e02, e28).
            if '(' not in proto or PORTS.search(proto):
                continue
        out.append('%s:%s' % (m.group('kw')[0], lbl))
    return out


def main():
    perdir = {}
    total = 0
    for root in sys.argv[1:]:
        for dp, _dn, fn in os.walk(root):
            for f in sorted(fn):
                if not f.endswith(('.sv', '.svh', '.v', '.vh')):
                    continue
                p = os.path.join(dp, f)
                hits = scan(p)
                if not hits:
                    continue
                total += len(hits)
                perdir[dp] = perdir.get(dp, 0) + len(hits)
                print('%4d  %s  [%s]' % (len(hits), p, ','.join(hits[:6]) +
                                         ('...' if len(hits) > 6 else '')))
    print('---- PER-DIRECTORY totals')
    for d in sorted(perdir, key=lambda x: -perdir[x]):
        print('%4d  %s' % (perdir[d], d))
    print('---- TOTAL fire sites in source: %d across %d directories'
          % (total, len(perdir)))


main()
