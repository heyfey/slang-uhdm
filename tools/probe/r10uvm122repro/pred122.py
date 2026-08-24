#!/usr/bin/env python3
"""r10uvm122 — A-PRIORI mover predictor, read off a PRISTINE uhdm-dump ALONE.

§ localBlockStmtSelBinds122 can only move a database that already holds BOTH
halves of the law's shape:

  (i)  a SELECT object (`bit_select` / `part_select` / `indexed_part_select` /
       `var_select`) sitting in an `assignment`'s `vpiLhs` slot — Surelog's
       block arm reads nothing else; and
  (ii) a `ref_obj` OF THE SAME NAME whose `vpiActual` is still a local
       variable DECLARATION (a `*_var` / `array_var`), which is the only
       starting point `endSelTrack`'s local pass re-points from.

The intersection of the two NAME sets is printed, one name per line, and it is
a deliberate OVER-approximation: it ignores the block chain, the declaring
block and the import-clone fence, so every database this law can touch is
named, and a named database that does not move is a fence doing its job.

  usage: pred122.py <dump>  ->  one candidate NAME per line
"""
import re, sys

SEL = re.compile(r'\\_(bit_select|part_select|indexed_part_select|var_select): '
                 r'(?:([^ (]+) )?(?:\(([^)]*)\))?')
REF = re.compile(r'\\_ref_obj: \(([^)]*)\)')
VAR = re.compile(r'\\_([a-z_]*var): ')


def leaf(n):
    return n.rsplit('::', 1)[-1].rsplit('.', 1)[-1]


def main():
    lines = open(sys.argv[1], errors='replace').read().split('\n')
    sels, refs = set(), set()
    for i, l in enumerate(lines):
        if l.strip() == '|vpiLhs:' and i + 1 < len(lines):
            m = SEL.search(lines[i + 1])
            if m:
                nm = m.group(3) or m.group(2) or ''
                if nm:
                    sels.add(leaf(nm))
        if l.strip() == '|vpiActual:' and i + 1 < len(lines) and VAR.search(lines[i + 1]):
            # walk back to the ref_obj this vpiActual belongs to
            base = len(l) - len(l.lstrip())
            for j in range(i - 1, max(-1, i - 12), -1):
                if (len(lines[j]) - len(lines[j].lstrip())) < base:
                    m = REF.search(lines[j])
                    if m:
                        refs.add(leaf(m.group(1)))
                    break
    for n in sorted(sels & refs):
        print(n)


main()
