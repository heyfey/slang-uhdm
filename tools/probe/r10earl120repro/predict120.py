#!/usr/bin/env python3
"""r10earl120 -- THE MOVER SET, PREDICTED BY NAME FROM THE PRISTINE DATABASES
ALONE, before the patched sweep exists.

MEASUREMENT ONLY.

    predict120.py <pristine.tsv>

§ paPaCopyTsInstance120 adds ONE field to a typespec § genCaTopLoopParamPaCopy105
already mints: `its5->Instance(sits5->Instance())`, copied from the SOURCE
typespec (the parameter's own elaborated `param_assign` Rhs typespec).  So a
cell moves EXACTLY WHEN

  (a) it is a param-substitution constant's own `int_typespec` (a `CELL` row --
      the census only holds those), AND
  (b) its `Instance` is `<null>` in the pristine database (nothing to change
      otherwise), AND
  (c) the SOURCE typespec it was copied from carries an `Instance`.

(c) is read off the pristine database with the `SRC` rows: a package
parameter's own declaration typespec, keyed by kind + span + signedness --
exactly the fields the mint copies -- with a non-`<null>` instance.  A cell
whose source has no home (a module localparam, a module parameter, a genvar)
CANNOT move, and that is the fence.

PREDICT-MOVE rows/cells are what `byteverify.sh` must then find, BY NAME, and
nothing else.  PREDICT-DECLINE counts the cells the law leaves alone so the
two numbers can be read against the census's STILL-WRONG.
"""
import sys
from collections import Counter, defaultdict


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    # (mode, test) -> {srckey: payloads}, and the cell rows
    srcs = defaultdict(lambda: defaultdict(Counter))
    cells = defaultdict(list)
    with open(sys.argv[1]) as f:
        for line in f:
            p = line.rstrip('\n').split('\t')
            if len(p) < 7 or p[0] != 'O':
                continue
            mode, test, tag, cnt, key, pay = p[1], p[2], p[3], int(p[4]), p[5], p[6]
            if tag == 'SRC':
                srcs[(mode, test)][key][pay] += cnt
            elif tag == 'CELL':
                cells[(mode, test)].append((cnt, key, pay))

    move = Counter()
    movecells = Counter()
    decline = Counter()
    declinecells = Counter()
    for row, lst in sorted(cells.items()):
        for cnt, key, pay in lst:
            # key = home | constant-span | ts-kind | ts-span | signed
            parts = key.split('|')
            if len(parts) < 5:
                continue
            srckey = parts[2] + '|' + parts[3] + '|' + parts[4]
            has_src_home = any(
                k != '<null>' for k in srcs[row].get(srckey, {}))
            if pay == '<null>' and has_src_home:
                move[row] += 1
                movecells[row] += cnt
            else:
                decline[row] += 1
                declinecells[row] += cnt

    print('PREDICT-MOVE rows=%d cells=%d' % (len(move), sum(movecells.values())))
    for row in sorted(move):
        print('  PREDICT-MOVE %-10s %-30s %d keys %d cells'
              % (row[0], row[1], move[row], movecells[row]))
    print('PREDICT-DECLINE rows=%d cells=%d'
          % (len(decline), sum(declinecells.values())))
    return 0


if __name__ == '__main__':
    sys.exit(main())
