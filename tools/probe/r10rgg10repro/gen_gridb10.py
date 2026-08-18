#!/usr/bin/env python3
"""r10rgg10/gen_gridb10.py — GRID B.  Grid A proved the flip is NOT the scope,
NOT the value and NOT the width: it is HOW THE PARAMETER IS READ.  Rggen's two
neighbouring bit-field blocks are the natural experiment:

    g_bit_field_0:  .INITIAL_VALUE (INITIAL_VALUE)   <- PARAMETER actual  -> decl bit_typespec
    g_bit_field_1:  .i_value       (INITIAL_VALUE)   <- PORT actual       -> BARE loc-less logic_typespec

Grid B separates the read kinds cleanly (Grid A's `pactual` cell wrapped the
read in a size cast and therefore tested something else), and adds the
enclosing-module axis (top module vs an INSTANTIATED child), because Rggen's
5843 ELAB module rows show no bare-logic at all.
"""
import os, sys
OUT = sys.argv[1] if len(sys.argv) > 1 else '/tmp/r10rgg10_gridb'

SINK = """module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule
"""
TYPES = [
    ('bit8',   'localparam bit [7:0] IV = {V};'),
    ('bit1',   'localparam bit IV = 1\'h1;'),
    ('int',    'localparam int IV = 171;'),
    ('logic8', 'localparam logic [7:0] IV = {V};'),
    ('bit8par','parameter bit [7:0] IV = {V};'),
]
VALS = [('nz', "8'hab"), ('zero', "8'h00")]
READS = [
    ('none',      ''),
    ('portplain', "sink #(8) u_s (.i_value(IV));"),
    ('pov',       "sink #(.W(IV)) u_s (.i_value('0));"),
    ('ca',        "wire [7:0] w; assign w = IV;"),
    ('caexpr',    "wire [7:0] w; assign w = IV + 1;"),
    ('portcast',  "sink #(8) u_s (.i_value(8'(IV)));"),
    ('both',      "sink #(.W(IV)) u_s (.i_value(IV));"),
    ('portcat',   "sink #(8) u_s (.i_value({4'h0,IV[3:0]}));"),
]
# (tag, where the localparam lives)
HOMES = ['topbody', 'topgen', 'childbody', 'childgen']


def build(home, decl, read):
    if home == 'topbody':
        return SINK + 'module top;\n  %s\n  %s\nendmodule\n' % (decl, read)
    if home == 'topgen':
        return SINK + 'module top;\n  generate if (1) begin : g\n    %s\n    %s\n  end endgenerate\nendmodule\n' % (decl, read)
    if home == 'childbody':
        return SINK + 'module child;\n  %s\n  %s\nendmodule\n' % (decl, read) + \
               'module top;\n  child u_c();\nendmodule\n'
    return SINK + 'module child;\n  generate if (1) begin : g\n    %s\n    %s\n  end endgenerate\nendmodule\n' % (decl, read) + \
           'module top;\n  child u_c();\nendmodule\n'


def main():
    os.makedirs(OUT, exist_ok=True)
    n = 0
    for home in HOMES:
        for tt, dtpl in TYPES:
            for vt, v in VALS:
                for rt, rtext in READS:
                    d = dtpl.format(V=v)
                    nm = '%s__%s__%s__%s' % (home, tt, vt, rt)
                    p = os.path.join(OUT, nm)
                    os.makedirs(p, exist_ok=True)
                    with open(os.path.join(p, 'top.sv'), 'wt') as f:
                        f.write(build(home, d, rtext))
                    n += 1
    print('cells=%d -> %s' % (n, OUT))


main()
