#!/usr/bin/env python3
"""r10rgg5/gen_grid.py -- write the measurement cells.

Every cell is a top module instantiating the REAL `rggen_or_reducer` (copied
from Surelog's own third_party tree at RUN time, never duplicated here) at a
chosen multiset of `N`, IN A CHOSEN ORDER.  The order matters: the whole point
is to separate "the FIRST evaluating instance decides the shared size" from
"the LARGEST N decides it".

Cell name encodes the instance list.  `x<k>` repeats.
"""
import os, sys

HERE = os.path.dirname(os.path.abspath(__file__))

# (cell, [N...])  -- instantiation order is the list order.
CELLS = [
    # --- the escaped/saturated regime, and the ORDER question
    ('a1_25',       [25]),
    ('a2_25x2',     [25, 25]),
    ('a3_25_2',     [25, 2]),
    ('a4_2_25',     [2, 25]),
    ('a5_20_25',    [20, 25]),
    ('a6_25_20',    [25, 20]),
    ('a7_20x2',     [20, 20]),
    ('a8_full',     [25] + [2]*11 + [20]),      # the Rggen multiplicity
    ('a9_2_20',     [2, 20]),
    # --- N sweep at x2 (does the regime depend on N alone?)
    ('b1_2x2',      [2, 2]),
    ('b2_4x2',      [4, 4]),
    ('b3_5x2',      [5, 5]),
    ('b4_6x2',      [6, 6]),
    ('b5_9x2',      [9, 9]),
    ('b6_13x2',     [13, 13]),
    ('b7_16x2',     [16, 16]),
    ('b8_21x2',     [21, 21]),
    ('b9_33x2',     [33, 33]),
    # --- ORDER / SIZE distinguishers: small first, large first
    ('c1_2_2_25',   [2, 2, 25]),
    ('c2_25_2_2',   [25, 2, 2]),
    ('c3_5_25',     [5, 25]),
    ('c4_25_5',     [25, 5]),
    ('c5_9_25',     [9, 25]),
    ('c6_33_25',    [33, 25]),
    ('c7_25_33',    [25, 33]),
    # --- WIDTH must be irrelevant to the argument constant
    ('d1_25_w8',    [25]),
    # --- the SHARED-WIDTH rule with NO escape anywhere (does the size still
    #     come from the first instance when nothing saturates?)
    ('e1_2_4',      [2, 4]),
    ('e2_4_2',      [4, 2]),
    ('e3_5_9',      [5, 9]),
    ('e4_9_5',      [9, 5]),
    ('e5_4_25',     [4, 25]),
    ('e6_25_4',     [25, 4]),
]
WIDTH = {'d1_25_w8': 8}

def main():
    for cell, ns in CELLS:
        d = os.path.join(HERE, cell)
        os.makedirs(d, exist_ok=True)
        w = WIDTH.get(cell, 2)
        with open(os.path.join(d, 'top_%s.sv' % cell), 'wt') as f:
            f.write('module top_%s;\n' % cell)
            for i, n in enumerate(ns):
                f.write('  rggen_or_reducer #(.WIDTH(%d), .N(%d)) u%02d '
                        '(.i_data(), .o_result());\n' % (w, n, i))
            f.write('endmodule\n')
    print('cells=%d' % len(CELLS))

if __name__ == '__main__':
    main()
