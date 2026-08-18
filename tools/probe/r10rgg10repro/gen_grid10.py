#!/usr/bin/env python3
"""r10rgg10/gen_grid10.py — MEASUREMENT ONLY.  Purpose-built GOLDEN grid for
the ELAB typespec of a parameter's param_assign Rhs constant.

The head this pass targets is Rggen's `g_bit_field_1`:

    if (1) begin : g_bit_field_1
      localparam bit [7:0] INITIAL_VALUE = 8'hab;
      ...  .i_value (INITIAL_VALUE)

whose ELAB param_assign Rhs constant carries, in GOLDEN, a ref_typespec whose
Actual is a LOC-LESS `logic_typespec` with BARE `UINT:7` / `UINT:0` bounds --
while the other 279 gen-scope localparams of the same design carry the
DECLARATION's `bit_typespec`.  The grid asks golden, cell by cell, WHICH
property flips that: the scope, the declared type, the initializer's value,
the way the parameter is READ, or the instance count.

Every cell is a self-contained `top.sv`; the runner compiles it with Surelog
`-parse` (Rggen's `default` mode is `-parse` and nothing else) and reads the
ELAB shape back with pcensus10.
"""
import itertools, os, sys

OUT = sys.argv[1] if len(sys.argv) > 1 else '/tmp/r10rgg10_grid'

SINK = """module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule
"""

# (tag, declaration text)  -- the LHS of the cell
TYPES = [
    ('bit8',    'localparam bit [7:0] IV = {V8};'),
    ('bit4',    'localparam bit [3:0] IV = {V4};'),
    ('bit1',    'localparam bit IV = {V1};'),
    ('logic8',  'localparam logic [7:0] IV = {V8};'),
    ('int',     'localparam int IV = {VI};'),
    ('untyped', 'localparam IV = {VI};'),
    ('sbit8',   'localparam bit signed [7:0] IV = {V8};'),
    ('bitN',    'localparam bit [WID-1:0] IV = {V8};'),
    ('bit8p',   'parameter bit [7:0] IV = {V8};'),
]
# (tag, V8, V4, V1, VI)
VALS = [
    ('zero',    "8'h00",  "4'h0",  "1'h0", '0'),
    ('nz',      "8'hab",  "4'h5",  "1'h1", '171'),
    ('nzdec',   "8'd171", "4'd5",  "1'd1", '171'),
    ('unsized', '171',    '5',     '1',    '171'),
    ('expr',    'BASE+1', 'BASE+1', '1',   'BASE+1'),
    ('concat',  "{4'ha,4'hb}", "{2'h1,2'h2}", "1'h1", '171'),
    ('call',    '$clog2(300)', '$clog2(9)', "1'h1", '$clog2(300)'),
]
# (tag, how the localparam is READ inside its scope)
READS = [
    ('port',   'sink #(8) u_s (.i_value(IV));'),
    ('ca',     'wire [7:0] w; assign w = IV;'),
    ('pactual','sink #(.W(8)) u_s (.i_value(8\'(IV)));'),
    ('none',   ''),
]
# (tag, open, close) -- the SCOPE the localparam is declared in
SCOPES = [
    ('genif_named',   'if (1) begin : g\n', 'end\n'),
    ('genif_unnamed', 'if (1) begin\n', 'end\n'),
    ('genfor',        'for (genvar gi = 0; gi < 2; gi++) begin : g\n', 'end\n'),
    ('gennest',       'if (1) begin : g\n if (1) begin : h\n', 'end\nend\n'),
    ('modbody',       '', ''),
]


def cell(tdecl, v, read, scope):
    tt, decl = tdecl
    vt, v8, v4, v1, vi = v
    rt, rtext = read
    st, so, sc = scope
    d = decl.format(V8=v8, V4=v4, V1=v1, VI=vi)
    body = so + '  ' + d + '\n  ' + rtext + '\n' + sc
    src = SINK + 'module top;\n  localparam int WID = 8;\n  localparam int BASE = 170;\n'
    if st == 'modbody':
        src += '  ' + d + '\n  ' + rtext + '\n'
    else:
        src += '  generate\n' + body + '  endgenerate\n'
    src += 'endmodule\n'
    return '%s_%s_%s_%s' % (st, tt, vt, rt), src


def main():
    os.makedirs(OUT, exist_ok=True)
    n = 0
    names = []
    for scope in SCOPES:
        for tdecl in TYPES:
            for v in VALS:
                for read in READS:
                    # keep the grid to the informative slice: the full
                    # read-axis only on the two types the head names.
                    if read[0] != 'port' and tdecl[0] not in ('bit8', 'bit4', 'int'):
                        continue
                    nm, src = cell(tdecl, v, read, scope)
                    d = os.path.join(OUT, nm)
                    os.makedirs(d, exist_ok=True)
                    with open(os.path.join(d, 'top.sv'), 'wt') as f:
                        f.write(src)
                    names.append(nm)
                    n += 1
    with open(os.path.join(OUT, 'CELLS.txt'), 'wt') as f:
        f.write('\n'.join(names) + '\n')
    print('cells=%d -> %s' % (n, OUT))


main()
