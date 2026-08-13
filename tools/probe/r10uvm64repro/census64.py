#!/usr/bin/env python3
"""r10uvm64 census kernel: count CANDIDATE ref_obj sites in ONE dump.

    usage: census64.py <dump-with-first-line-stripped>   -> prints one integer

A CANDIDATE is a `ref_obj` occurrence that
  (1) carries NO `vpiActual` own-field at its FULLEST occurrence, and
  (2) whose short name matches a variable that some `begin` in this database
      lists under `vpiVariables`.

Both facts are readable off our own PRISTINE dump, which is what makes the
prediction computable before the patched binary exists.  The scanner is a
SUPERSET: the dump prints neither the control-body depth, nor whether the
enclosing subroutine is an in-body class method, nor whether the reference
sits in an if/case CONDITION.  See census64.sh for why that asymmetry is the
point.

THE FULLEST-OCCURRENCE RULE IS NOT OPTIONAL.  uhdm-dump prints a bound ref_obj
once with its fields and again, under every other parent, as a bare one-line
back-reference.  Counting bare occurrences would report almost every bound
reference in the database as a candidate.
"""
import re
import sys

REF = re.compile(r'^(\s*)\\_ref_obj: \(([^)]*)\), line:(\d+):(\d+)')
ANY = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?')
FLD = re.compile(r'^(\s*)\|(\w+):')


def main():
    lines = open(sys.argv[1], 'rt', errors='replace').read().splitlines()
    # Pass 1: the names a `begin` lists under vpiVariables.
    blocklocals = set()
    for i, ln in enumerate(lines):
        m = ANY.match(ln)
        if not m or m.group(2) != 'begin':
            continue
        own = len(m.group(1)) + 2
        invars = False
        for j in range(i + 1, len(lines)):
            nx = lines[j]
            if not nx.strip():
                break
            ind = len(nx) - len(nx.lstrip())
            if ind < own:
                break
            if ind != own:
                continue
            f = FLD.match(nx)
            if f:
                invars = f.group(2) == 'vpiVariables'
                continue
            c = ANY.match(nx)
            if c and invars and c.group(3):
                blocklocals.add(c.group(3).split('::')[-1])
    # Pass 2: ref_obj fullest occurrences, keyed by span.
    best = {}
    for i, ln in enumerate(lines):
        m = REF.match(ln)
        if not m:
            continue
        own = len(m.group(1)) + 2
        name, l, c = m.group(2), int(m.group(3)), int(m.group(4))
        fields = set()
        for j in range(i + 1, len(lines)):
            nx = lines[j]
            if not nx.strip():
                break
            ind = len(nx) - len(nx.lstrip())
            if ind < own:
                break
            if ind != own:
                continue
            f = FLD.match(nx)
            if f:
                fields.add(f.group(2))
        key = (l, c, name)
        if key not in best or len(fields) > len(best[key]):
            best[key] = fields
    n = 0
    for (l, c, name), fields in best.items():
        if 'vpiActual' in fields:
            continue
        if name.split('::')[-1] in blocklocals:
            n += 1
    print(n)


if __name__ == '__main__':
    main()
