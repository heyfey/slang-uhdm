#!/usr/bin/env python3
"""r10rgg13/gen_grid13.py -- THE GRIDS this pass's law is stated on.

  usage: gen_grid13.py <outdir> [A|B|C]

The question: what is the CONSTANT that sits at a call-ARGUMENT position inside
a `param_assign` Rhs whose call golden keeps SYMBOLIC?

GRID A -- the ARGUMENT-SHAPE x FORMAL-TYPE grid (24 cells).  `mid` declares
    localparam bit [P-1:0][15:0] LP = f(<ARG>);
(a MULTIDIMENSIONAL localparam, so Surelog compiles the initializer with
Reduce::No and the call SURVIVES into the elaborated view) and is instantiated
SIX times under `top`, one per OVERRIDE shape, so every cell answers the
per-instance question as well:
    u_dec #(.P(2))  u_hex #(.P(8'h03))  u_bin #(.P(4'b0101))
    u_expr #(.P(1+3))  u_prm #(.P(TOPP))  u_def (no override)
6 ARGUMENT SHAPES  x  4 FORMAL TYPES.

GRID B -- the HOME x LOCALPARAM-TYPE grid (12 cells): module body / generate-if
/ generate-for / package, against a P-dependent packed-2D localparam, a FIXED
packed-2D one and a plain `int` one (the control that golden FOLDS whole).

GRID C -- the DECLARATION-DEFAULT grid (3 cells): the un-overridden instance's
copy, when the declaration default is a decimal literal / a hex literal / an
expression.

Every cell is a SINGLE FILE with a `top`, so `cell13.sh` can run it in the
DEFAULT mode both corpora use (`surelog -parse <src>` / `slang <src>
--single-unit`).
"""
import os, sys

# ------------------------------------------------------------------ Grid A
# formal type of the callee's single argument
FORMALT = {
    'fint':    'int n',
    'fbit8':   'bit [7:0] n',
    'flogicp': 'logic [P-1:0] n',
    'funtyp':  'n',
}
# the ARGUMENT written at the call site
ARGSHAPE = {
    'bare':  'P',        # the law's shape
    'expr':  'P+1',
    'sel':   'ARRP[1]',
    'nest':  'fnest(P)',
    'lit':   '3',
    'other': 'Q',        # a bare LOCALPARAM name (not a port parameter)
}

def mid_module(formal, argexpr, defshape='hex'):
    default = {'lit': '1', 'hex': "8'h07", 'expr': '2+5'}[defshape]
    return f"""module mid #(
  parameter int WIDTH = 8,
  parameter int P = {default}
)(
  output logic [WIDTH-1:0] o
);
  parameter bit [3:0][7:0] ARRP = 32'h04030201;
  localparam int Q = 5;
  function automatic int fnest(int n);
    return n;
  endfunction
  function automatic bit [P-1:0][15:0] flp({formal});
    bit [P-1:0][15:0] list;
    list = '0;
    list[0] = 16'(n);
    return list;
  endfunction
  localparam bit [P-1:0][15:0] LP = flp({argexpr});
  assign o = LP[0][WIDTH-1:0];
endmodule
"""

TOP_INSTANCES = """
module top;
  localparam int TOPP = 6;
  logic [7:0] o1, o2, o3, o4, o5, o6;
  mid #(.P(2))       u_dec  (.o(o1));
  mid #(.P(8'h03))   u_hex  (.o(o2));
  mid #(.P(4'b0101)) u_bin  (.o(o3));
  mid #(.P(1+3))     u_expr (.o(o4));
  mid #(.P(TOPP))    u_prm  (.o(o5));
  mid                u_def  (.o(o6));
endmodule
"""

def gridA(out):
    n = 0
    for ft, formal in FORMALT.items():
        for a, argexpr in ARGSHAPE.items():
            cell = f"{ft}__{a}"
            d = os.path.join(out, cell)
            os.makedirs(d, exist_ok=True)
            with open(os.path.join(d, 'top.sv'), 'w') as f:
                f.write(mid_module(formal, argexpr) + TOP_INSTANCES)
            n += 1
    return n

# ------------------------------------------------------------------ Grid B
LPTYPE = {
    'p2dp':   ('bit [P-1:0][15:0]', 'bit [P-1:0][15:0]'),   # P-dependent mdim
    'p2dfix': ('bit [1:0][15:0]',   'bit [1:0][15:0]'),     # fixed mdim
    'plain':  ('int',               'int'),                 # the FOLD control
}

def mid_home(home, lpt, rett):
    # The FUNCTION always lives in the module body: slang refuses "a function
    # declared inside a generate block in a constant expression", so a
    # gen-scope-homed function is not a cell this grid can build at all.  The
    # axis under test is the home of the LOCALPARAM (the param_assign that owns
    # the call), which is exactly what r10rgg11's law turned on.
    body_fn = f"""  function automatic {rett} flp(int n);
    {rett} list;
    list = '0;
    return list;
  endfunction
"""
    lp = f"  localparam {lpt} LP = flp(P);\n"
    if home == 'mod':
        inner = body_fn + lp + "  assign o = LP[0];\n"
    elif home == 'genif':
        inner = (body_fn + "  if (1) begin : g\n  " + lp +
                 "  end\n  assign o = g.LP[0];\n")
    elif home == 'genfor':
        inner = (body_fn + "  for (genvar gi = 0; gi < 2; gi++) begin : g\n  " +
                 lp + "  end\n  assign o = g[0].LP[0];\n")
    else:
        inner = ""
    return f"""module mid #(
  parameter int P = 8'h07
)(
  output logic o
);
{inner}endmodule
"""

PKG_TMPL = """package gp;
  parameter int P = 8'h07;
  function automatic %s flp(int n);
    %s list;
    list = '0;
    return list;
  endfunction
  localparam %s LP = flp(P);
endpackage

module top;
  logic o;
  assign o = gp::LP[0];
endmodule
"""

TOP_B = """
module top;
  localparam int TOPP = 6;
  logic o1, o2, o3, o4, o5, o6;
  mid #(.P(2))       u_dec  (.o(o1));
  mid #(.P(8'h03))   u_hex  (.o(o2));
  mid #(.P(4'b0101)) u_bin  (.o(o3));
  mid #(.P(1+3))     u_expr (.o(o4));
  mid #(.P(TOPP))    u_prm  (.o(o5));
  mid                u_def  (.o(o6));
endmodule
"""

def gridB(out):
    n = 0
    for home in ('mod', 'genif', 'genfor', 'pkg'):
        for lk, (lpt, rett) in LPTYPE.items():
            cell = f"{home}__{lk}"
            d = os.path.join(out, cell)
            os.makedirs(d, exist_ok=True)
            with open(os.path.join(d, 'top.sv'), 'w') as f:
                if home == 'pkg':
                    lpt2 = lpt.replace('P-1', '1')   # no per-instance P in a pkg
                    rett2 = rett.replace('P-1', '1')
                    f.write(PKG_TMPL % (rett2, rett2, lpt2))
                else:
                    f.write(mid_home(home, lpt, rett) + TOP_B)
            n += 1
    return n

# ------------------------------------------------------------------ Grid C
def gridC(out):
    n = 0
    for ds in ('lit', 'hex', 'expr'):
        d = os.path.join(out, f"def__{ds}")
        os.makedirs(d, exist_ok=True)
        with open(os.path.join(d, 'top.sv'), 'w') as f:
            f.write(mid_module('int n', 'P', ds) + TOP_INSTANCES)
        n += 1
    return n

if __name__ == '__main__':
    out = sys.argv[1]
    which = (sys.argv[2] if len(sys.argv) > 2 else 'A').upper()
    os.makedirs(out, exist_ok=True)
    n = {'A': gridA, 'B': gridB, 'C': gridC}[which](out)
    print(f"grid {which}: {n} cells -> {out}")
