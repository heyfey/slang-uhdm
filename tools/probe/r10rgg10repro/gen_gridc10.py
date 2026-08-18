#!/usr/bin/env python3
"""r10rgg10/gen_gridc10.py — GRID C.  Grid B fixed the axis (HOW the parameter
is READ) and showed the law is home-blind and value-blind.  Grid C walks the
READ axis to its edges: procedural reads, positional ports, reads from a NESTED
scope, an LHS index read, a function-call argument, a generate condition.

The mechanism this is testing is `CompileHelper::getObject`
(CompileExpression.cpp:305-323): when a NAME resolves to a `param_assign`,
Surelog takes `passign->Rhs()` — THE SHARED DECLARATION CONSTANT — and, if the
enclosing ModuleInstance has a value for that name, calls
`setRange(that constant, value)`, which REPLACES its typespec IN PLACE with a
fresh LOC-LESS `logic_typespec` whose bounds are bare `UINT:<l>` / `UINT:<r>`
(CompileHelper.cpp:5417).  `if (instance)` is the gate, so the prediction Grid
C tests is: only expressions Surelog compiles WITH AN INSTANCE (netlist
elaboration: cont_assign RHS, instance port connections) rewrite it; a
definition-level expression (a process body) does not.
"""
import os, sys
OUT = sys.argv[1] if len(sys.argv) > 1 else '/tmp/r10rgg10_gridc'
SINK = """module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule
"""
FN = """function automatic logic [7:0] f(input logic [7:0] a);
  f = a;
endfunction
"""
TYPES = [('bit8', "localparam bit [7:0] IV = 8'hab;"),
         ('logic8', "localparam logic [7:0] IV = 8'hab;")]
READS = [
    ('proc_always',  "logic [7:0] r; always_comb r = IV;"),
    ('proc_initial', "logic [7:0] r; initial r = IV;"),
    ('portpos',      "sink u_s (IV);"),
    ('portnamed',    "sink #(8) u_s (.i_value(IV));"),
    ('nestedport',   "if (1) begin : n\n      sink #(8) u_s (.i_value(IV));\n    end"),
    ('nestedca',     "if (1) begin : n\n      wire [7:0] w; assign w = IV;\n    end"),
    ('caidx',        "wire [7:0] w; assign w[IV[0]] = 1'b0;"),
    ('funcall',      FN + "  wire [7:0] w; assign w = f(IV);"),
    ('gencond',      "if (IV[0]) begin : c\n      wire q;\n    end"),
    ('caonly',       "wire [7:0] w; assign w = IV;"),
]
HOMES = ['topbody', 'topgen', 'childbody', 'childgen']


def build(home, decl, read):
    # a read text containing `if (` must sit inside a generate region
    gen = 'if (' in read or 'begin :' in read
    body = '  %s\n  %s\n' % (decl, ('generate\n  %s\n  endgenerate\n' % read) if gen else read)
    if home == 'topbody':
        return SINK + 'module top;\n' + body + 'endmodule\n'
    if home == 'topgen':
        return SINK + 'module top;\n  generate if (1) begin : g\n' + body + '  end endgenerate\nendmodule\n'
    if home == 'childbody':
        return SINK + 'module child;\n' + body + 'endmodule\nmodule top;\n  child u_c();\nendmodule\n'
    return SINK + 'module child;\n  generate if (1) begin : g\n' + body + '  end endgenerate\nendmodule\nmodule top;\n  child u_c();\nendmodule\n'


def main():
    os.makedirs(OUT, exist_ok=True)
    n = 0
    for home in HOMES:
        for tt, decl in TYPES:
            for rt, rtext in READS:
                nm = '%s__%s__nz__%s' % (home, tt, rt)
                p = os.path.join(OUT, nm)
                os.makedirs(p, exist_ok=True)
                with open(os.path.join(p, 'top.sv'), 'wt') as f:
                    f.write(build(home, decl, rtext))
                n += 1
    print('cells=%d -> %s' % (n, OUT))


main()
