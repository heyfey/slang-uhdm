#!/usr/bin/env python3
"""r10rgg9/gen_grid9.py -- write every grid cell for
   § srlgCondOpInstValueTernFold9.

MEASUREMENT ONLY.  Every cell is dispatched to REAL SURELOG by run_grid9.sh;
the official uhdm-cmp remains the sole acceptance judge.

The head this pass targets:

    assign write_data[0] = (WRITABLE) ? {WORDS{register_if.write_data}} : '0;

golden folds it, in the ELAB view only, at the two instances where the
INSTANCE parameter value is 0, to a LOC-LESS `INT:0 vpiSize 64
vpiConstType 7` constant.

AXES
  1. predicate provenance   bare-literal module param / per-instance override
                            (BOTH directions) / localparam / package param /
                            expression / && || / net / genvar / enum
  2. taken-arm kind         '0 '1 0 1 42 4'hF 4'b1010 -1 param concat
                            non-const-concat net nested-ternary $clog2 string
  3. LHS shape              unpacked-array bit_select (the head) / plain net /
                            vector bit-select / part-select / concat /
                            interface member / dotted
  4. context                module body / generate scope / interface /
                            procedural (must NOT fold) / port connection /
                            param initializer
  5. instance count         1, 2 and 3 instances with DIFFERENT overrides
"""
import os

ROOT = os.path.dirname(os.path.abspath(__file__))
CELLS = os.path.join(ROOT, 'cells')

# A module whose only job is to hold one cont-assign whose RHS is a ternary
# with a parameter predicate.  `sig` is a non-constant net so a taken
# non-constant arm can never be valued.
def mod(body, params='parameter bit P = 0', ports='', extra=''):
    return f"""module m #(
  {params}
)({ports});
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];
{extra}
{body}
endmodule
"""

def top(insts):
    return "module top;\n" + insts + "endmodule\n"

CELLS_SRC = {}

def add(name, src):
    CELLS_SRC[name] = src

# ---------------------------------------------------------------- 1. PROVENANCE
# The head's own LHS shape (bit_select of an UNPACKED array): golden leaves
# `lhs->Typespec()` null, `tps` stays null and the trailing
# `if (simplified == false)` reduce installs the reducer's OWN 64-bit constant.
HEADCA = "  assign arr[0] = (P) ? {2{sig}} : '0;\n"

add('p_decl0', mod(HEADCA, 'parameter bit P = 0') + top("  m u_a();\n"))
add('p_decl1', mod(HEADCA, 'parameter bit P = 1') + top("  m u_a();\n"))
# THE REFUTATION CELLS: rgg8's clause 1 (the arm is picked from the
# DECLARATION) must NOT transfer.  p_ov10 declares 1 and overrides to 0.
add('p_ov10', mod(HEADCA, 'parameter bit P = 1') + top("  m #(.P(0)) u_a();\n"))
add('p_ov01', mod(HEADCA, 'parameter bit P = 0') + top("  m #(.P(1)) u_a();\n"))
add('p_split', mod(HEADCA, 'parameter bit P = 0') +
    top("  m #(.P(0)) u_a();\n  m #(.P(1)) u_b();\n"))
add('p_three', mod(HEADCA, 'parameter bit P = 1') +
    top("  m #(.P(0)) u_a();\n  m #(.P(1)) u_b();\n  m #(.P(0)) u_c();\n"))
# a localparam DERIVED from the (overridden) parameter
add('p_localparam', mod("  assign arr[0] = (LP) ? {2{sig}} : '0;\n",
                        'parameter bit P = 1', extra="  localparam bit LP = P & 1'b1;\n") +
    top("  m #(.P(0)) u_a();\n  m #(.P(1)) u_b();\n"))
# a PACKAGE parameter
add('p_pkgparam', """package pk;
  parameter bit PP = 0;
endpackage
""" + mod("  assign arr[0] = (pk::PP) ? {2{sig}} : '0;\n") + top("  m u_a();\n"))
add('p_pkgimport', """package pk2;
  parameter bit PP2 = 0;
endpackage
""" + """module m
  import pk2::*;
#(
  parameter bit P = 0
)();
  logic sig;
  logic [7:0] arr[2];
  assign arr[0] = (PP2) ? {2{sig}} : '0;
endmodule
""" + top("  m u_a();\n"))
# an EXPRESSION predicate
add('p_expr_eq', mod("  assign arr[0] = (P == 1'b1) ? {2{sig}} : '0;\n",
                     'parameter bit P = 0') + top("  m #(.P(0)) u_a();\n"))
add('p_expr_and', mod("  assign arr[0] = (P && Q) ? {2{sig}} : '0;\n",
                      'parameter bit P = 1, parameter bit Q = 0') +
    top("  m #(.P(1), .Q(0)) u_a();\n"))
add('p_expr_or', mod("  assign arr[0] = (P || Q) ? {2{sig}} : '0;\n",
                     'parameter bit P = 0, parameter bit Q = 0') +
    top("  m #(.P(0), .Q(0)) u_a();\n"))
add('p_expr_not', mod("  assign arr[0] = (!P) ? '1 : '0;\n",
                      'parameter bit P = 0') + top("  m #(.P(0)) u_a();\n"))
# a NET predicate -- must NOT fold (getValue returns null, constantOperands
# goes false and the whole operation is returned unreduced).
add('p_net', mod("  assign arr[0] = (sig) ? {2{sig}} : '0;\n") + top("  m u_a();\n"))
# an INT parameter, not a bit
add('p_int', mod("  assign arr[0] = (PI) ? {2{sig}} : '0;\n",
                 'parameter int PI = 0') + top("  m #(.PI(0)) u_a();\n"))
add('p_intwide', mod("  assign arr[0] = (PI) ? {2{sig}} : '0;\n",
                     'parameter int PI = 0') + top("  m #(.PI(7)) u_a();\n"))
# an ENUM-constant predicate
add('p_enum', """package pe;
  typedef enum bit {E_OFF, E_ON} e_t;
endpackage
""" + """module m
  import pe::*;
#();
  logic sig;
  logic [7:0] arr[2];
  assign arr[0] = (E_OFF) ? {2{sig}} : '0;
endmodule
""" + top("  m u_a();\n"))
# a GENVAR predicate inside a generate loop
add('p_genvar', """module m #(
  parameter int N = 2
)();
  logic sig;
  logic [7:0] arr[4];
  genvar g;
  generate
    for (g = 0; g < 2; ++g) begin : gb
      assign arr[g] = (g) ? {2{sig}} : '0;
    end
  endgenerate
endmodule
""" + top("  m u_a();\n"))

# --------------------------------------------------------------------- 2. ARMS
def armcell(name, arm_true, arm_false, params='parameter bit P = 0',
            extra='', ov='.P(0)'):
    add(name, mod(f"  assign arr[0] = (P) ? {arm_true} : {arm_false};\n",
                  params, extra=extra) + top(f"  m #({ov}) u_a();\n"))

armcell('a_u0',      "{2{sig}}", "'0")
armcell('a_u1',      "{2{sig}}", "'1")
armcell('a_dec0',    "{2{sig}}", "0")
armcell('a_dec42',   "{2{sig}}", "42")
armcell('a_hex',     "{2{sig}}", "4'hF")
armcell('a_bin',     "{2{sig}}", "4'b1010")
armcell('a_neg',     "{2{sig}}", "-1")
armcell('a_wide',    "{2{sig}}", "64'hDEAD_BEEF_CAFE_BABE")
armcell('a_over64',  "{2{sig}}", "72'h1_0000_0000_0000_0000")
armcell('a_xz',      "{2{sig}}", "4'bxx01")
armcell('a_str',     "{2{sig}}", '"ab"')
armcell('a_param',   "{2{sig}}", "Q", params='parameter bit P = 0, parameter int Q = 5')
armcell('a_concat',  "{2{sig}}", "{2'b10, 2'b11}")
armcell('a_repl',    "{2{sig}}", "{4{1'b1}}")
armcell('a_net',     "{2{sig}}", "sig")
armcell('a_nested',  "{2{sig}}", "((P) ? 1 : 2)")
armcell('a_clog2',   "{2{sig}}", "$clog2(9)")
armcell('a_localp',  "{2{sig}}", "LP", extra="  localparam int LP = 7;\n")
# TAKEN = the TRUE arm (P overridden to 1)
armcell('a_true_c',  "42", "{2{sig}}", ov='.P(1)', params='parameter bit P = 0')
armcell('a_true_u0', "'0", "{2{sig}}", ov='.P(1)', params='parameter bit P = 0')
armcell('a_true_net',"sig", "{2{sig}}", ov='.P(1)', params='parameter bit P = 0')
# both arms constant, so BOTH directions fold
armcell('a_bothc0',  "7", "9", ov='.P(0)')
armcell('a_bothc1',  "7", "9", ov='.P(1)')
# UNTAKEN arm is unvaluable but the taken one is a plain constant
armcell('a_untaken_call', "f(sig)", "'0", extra="""  function automatic logic [7:0] f(logic x);
    return {8{x}};
  endfunction
""")

# ------------------------------------------------------------------- 3. LHS/CTX
add('l_plainnet', mod("  logic [7:0] o;\n  assign o = (P) ? {2{sig}} : '0;\n") +
    top("  m #(.P(0)) u_a();\n"))
add('l_plainnet1', mod("  logic o;\n  assign o = (P) ? sig : '0;\n") +
    top("  m #(.P(0)) u_a();\n"))
add('l_plainnet_i', mod("  logic [7:0] o;\n  assign o = (P) ? {2{sig}} : 42;\n") +
    top("  m #(.P(0)) u_a();\n"))
add('l_vecbit', mod("  assign vec[0] = (P) ? sig : '0;\n") + top("  m #(.P(0)) u_a();\n"))
add('l_partsel', mod("  assign vec[3:0] = (P) ? {4{sig}} : '0;\n") +
    top("  m #(.P(0)) u_a();\n"))
add('l_concat', mod("  logic a1, b1;\n  assign {a1, b1} = (P) ? {2{sig}} : '0;\n") +
    top("  m #(.P(0)) u_a();\n"))
add('l_iface', """interface bus_t;
  logic [7:0] d;
  modport slave (output d);
endinterface
module m #(
  parameter bit P = 0
)(bus_t.slave bif);
  logic sig;
  assign bif.d = (P) ? {2{sig}} : '0;
endmodule
module top;
  bus_t bi();
  m #(.P(0)) u_a(.bif(bi));
endmodule
""")
add('c_gen', """module m #(
  parameter bit P = 0
)();
  logic sig;
  logic [7:0] arr[2];
  generate
    if (1) begin : gb
      assign arr[0] = (P) ? {2{sig}} : '0;
    end
  endgenerate
endmodule
""" + top("  m #(.P(0)) u_a();\n"))
add('c_iface_body', """interface bus_t2 #(
  parameter bit P = 0
)();
  logic sig;
  logic [7:0] arr[2];
  assign arr[0] = (P) ? {2{sig}} : '0;
endinterface
module top;
  bus_t2 #(.P(0)) bi();
endmodule
""")
# PROCEDURAL: must NOT fold (writeCont_assign never sees it)
add('c_proc', mod("""  logic [7:0] o;
  always_comb o = (P) ? {2{sig}} : '0;
""") + top("  m #(.P(0)) u_a();\n"))
# PORT CONNECTION
add('c_port', """module s(input logic [7:0] i);
endmodule
module m #(
  parameter bit P = 0
)();
  logic sig;
  s u_s(.i((P) ? {2{sig}} : '0));
endmodule
""" + top("  m #(.P(0)) u_a();\n"))
# PARAM INITIALIZER (owned by other laws -- measured, never claimed)
add('c_paraminit', mod("  assign arr[0] = Z;\n", 'parameter bit P = 0',
                       extra="  localparam int Z = (P) ? 3 : 4;\n") +
    top("  m #(.P(0)) u_a();\n"))
# VAR-DECL INIT
add('c_varinit', mod("", 'parameter bit P = 0',
                     extra="  logic [7:0] v0 = (P) ? 8'd3 : 8'd4;\n") +
    top("  m #(.P(0)) u_a();\n"))
# a CHILD instance one level down (the head lives 3 levels deep)
add('c_deep', """module leaf #(
  parameter bit P = 0
)();
  logic sig;
  logic [7:0] arr[2];
  assign arr[0] = (P) ? {2{sig}} : '0;
endmodule
module mid #(
  parameter bit P = 0
)();
  leaf #(.P(P)) u_l();
endmodule
module top;
  mid #(.P(0)) u_a();
  mid #(.P(1)) u_b();
endmodule
""")
# the head's OWN shape, verbatim: a multi-concat true arm over a hier_path
add('c_headshape', """interface reg_if;
  logic [31:0] write_data;
  modport register (input write_data);
endinterface
module m #(
  parameter bit WRITABLE = 1,
  parameter int WORDS = 1
)(reg_if.register register_if);
  logic [31:0] write_data[2];
  assign write_data[0] = (WRITABLE) ? {WORDS{register_if.write_data}} : '0;
endmodule
module top;
  reg_if ri();
  m #(.WRITABLE(0)) u_a(.register_if(ri));
  m #(.WRITABLE(1)) u_b(.register_if(ri));
endmodule
""")

def main():
    os.makedirs(CELLS, exist_ok=True)
    for name, src in sorted(CELLS_SRC.items()):
        d = os.path.join(CELLS, name)
        os.makedirs(d, exist_ok=True)
        with open(os.path.join(d, 'dut.sv'), 'wt') as f:
            f.write(src)
    print('cells=%d' % len(CELLS_SRC))

if __name__ == '__main__':
    main()
