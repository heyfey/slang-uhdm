#!/usr/bin/env python3
"""r10vrgg7/gen_grid.py -- the VERIFIER's adversarial cells for
§ genIfUnvaluedFuncParam7.

Every cell is one `dut.sv`: a module `sub` holding the generate chain, and a
`top` that instantiates it.  Both arms of a two-arm chain are named `g_reduce`
(exactly rggen_or_reducer's shape) and are told apart ONLY by CONTENT --
`a_mark` in the `if` arm, `b_mark` in the `else`, `c_mark` in a third arm.

The POISON function is rggen_or_reducer's own get_next_n body -- a select of a
function-scope array object under a poison-propagating operator -- over a PLAIN
VALUED array (r10rgg7 measured that the saturated regime is not the axis).
`RAW` is therefore a parameter Surelog's ExprEval never values.
"""
import os

ROOT = os.path.dirname(os.path.abspath(__file__))
CELLS = os.path.join(ROOT, 'cells')

POISON = """  function automatic int cnt(bit [7:0][15:0] l);
    int r;
    r = 0;
    for (int i = 0;i < 8;++i) begin
      r += ((l[i] != 0) ? 1 : 0);
    end
    return r;
  endfunction
  localparam bit [7:0][15:0] LIST = '{16'd1,16'd2,16'd3,16'd4,16'd5,16'd6,16'd7,16'd8};
"""
FOLD = """  function automatic int addup(int n);
    int r;
    r = 0;
    for (int i = 0;i < n;++i) begin
      r += 1;
    end
    return r;
  endfunction
"""


def arm(mark, extra=''):
    return ("      logic %s;\n      always_comb begin\n        %s = 1'b1;\n"
            "      end\n%s" % (mark, mark, extra))


def two_arm(cond, named=True):
    if named:
        return ("  generate\n    if (%s) begin : g_reduce\n%s    end\n"
                "    else begin : g_reduce\n%s    end\n  endgenerate\n"
                % (cond, arm('a_mark'), arm('b_mark')))
    return ("  generate\n    if (%s) begin\n%s    end\n"
            "    else begin\n%s    end\n  endgenerate\n"
            % (cond, arm('a_mark'), arm('b_mark')))


def sub(body, ports='parameter int N = 8'):
    return ("module sub #(\n  %s\n)(\n  output logic o_result\n);\n%s"
            "endmodule\n" % (ports, body))


TOP1 = "\nmodule top;\n  logic r0;\n  sub #(.N(8)) u0 (.o_result(r0));\nendmodule\n"

CELLS_SRC = {}


def add(name, text):
    CELLS_SRC[name] = text


# ------------------------------------------------------------------ CONTROLS
add('c_lit', sub("  localparam int NEXT = 8;\n" + two_arm('NEXT > 1')) + TOP1)
add('c_fold', sub(FOLD + "  localparam int NEXT = addup(8);\n"
                  + two_arm('NEXT > 1')) + TOP1)
add('c_clog2lit', sub("  localparam int NEXT = $clog2(8);\n"
                      + two_arm('NEXT > 1')) + TOP1)
add('c_mdpacked', sub(
    """  function automatic bit [7:0][15:0] mkfold();
    bit [7:0][15:0] l;
    for (int i = 0;i < 8;++i) begin
      l[i] = 16'd2;
    end
    return l;
  endfunction
  localparam bit [7:0][15:0] QQ = mkfold();
""" + two_arm('QQ[0] > 1')) + TOP1)
# an unvalued RAW EXISTS in scope but the condition does not read it.
add('c_unread', sub(POISON + "  localparam int RAW = cnt(LIST);\n"
                    "  logic dummy;\n  always_comb dummy = (RAW != 0);\n"
                    + two_arm('N > 1')) + TOP1)
# a FOLDING call written directly in the condition.
add('c_condcall', sub(POISON + FOLD + "  localparam int RAW = cnt(LIST);\n"
                      "  logic dummy;\n  always_comb dummy = (RAW != 0);\n"
                      + two_arm('addup(8) > 1')) + TOP1)

# ---------------------------------------------------- BASELINE: the law itself
add('b_poison', sub(POISON + "  localparam int RAW = cnt(LIST);\n"
                    + two_arm('RAW > 1')) + TOP1)
add('b_unnamed', sub(POISON + "  localparam int RAW = cnt(LIST);\n"
                     + two_arm('RAW > 1', named=False)) + TOP1)

# ------------------------------------------------ S: SCOPE / MIS-BIND HAZARDS
# THE SHADOW.  The condition reads gp::NEXT (a plain LITERAL 8, valued), while
# the module body ALSO declares an unvalued localparam of the SAME NAME.  A
# predicate that resolves the bare identifier `NEXT` in the module scope binds
# the WRONG symbol and falsifies a condition golden reads as TRUE.
add('s_pkgshadow', """package gp;
  localparam int NEXT = 8;
endpackage

""" + sub(POISON + "  localparam int NEXT = cnt(LIST);\n"
          "  logic dummy;\n  always_comb dummy = (NEXT != 0);\n"
          + two_arm('gp::NEXT > 1')) + TOP1)
# CONTROL for the shadow: same package read, NO local NEXT at all.
add('s_pkgnoshadow', """package gp;
  localparam int NEXT = 8;
endpackage

""" + sub(POISON + "  localparam int RAW = cnt(LIST);\n"
          "  logic dummy;\n  always_comb dummy = (RAW != 0);\n"
          + two_arm('gp::NEXT > 1')) + TOP1)
# THE SHADOW, second face: a struct-parameter MEMBER named like a local.
add('s_memberdot', sub(POISON + """  typedef struct packed { int nxt; } cfg_t;
  localparam cfg_t CFG = '{nxt: 8};
  localparam int nxt = cnt(LIST);
  logic dummy;
  always_comb dummy = (nxt != 0);
""" + two_arm('CFG.nxt > 1')) + TOP1)
# THE SHADOW, third face: an inner generate scope declares the VALUED one.
add('s_genshadow', sub(POISON + "  localparam int NEXT = cnt(LIST);\n"
                       + """  generate
    if (N > 0) begin : g_outer
      localparam int NEXT = 8;
      if (NEXT > 1) begin : g_reduce
""" + arm('a_mark') + """      end
      else begin : g_reduce
""" + arm('b_mark') + """      end
    end
  endgenerate
""") + TOP1)

# ----------------------------------------------- W: PROVENANCE OF THE VALUE
add('w_bits', sub(POISON + "  localparam int RAW = cnt(LIST);\n"
                  "  localparam int NEXT = $bits(RAW);\n"
                  + two_arm('NEXT > 1')) + TOP1)
add('w_clog2', sub(POISON + "  localparam int RAW = cnt(LIST);\n"
                   "  localparam int NEXT = $clog2(RAW);\n"
                   + two_arm('NEXT > 1')) + TOP1)
add('w_ternarydead', sub(POISON + "  localparam int RAW = cnt(LIST);\n"
                         "  localparam int NEXT = (1) ? 8 : RAW;\n"
                         + two_arm('NEXT > 1')) + TOP1)
add('w_or', sub(POISON + "  localparam int RAW = cnt(LIST);\n"
                + two_arm('(N > 1) || (RAW > 1)')) + TOP1)
add('w_andfalse', sub(POISON + "  localparam int RAW = cnt(LIST);\n"
                      + two_arm('(N < 0) && (RAW > 1)')) + TOP1)
add('w_indirect_minus', sub(POISON + "  localparam int RAW = cnt(LIST);\n"
                            + two_arm('(RAW - 1) > 0')) + TOP1)
add('w_indirect_ne', sub(POISON + "  localparam int RAW = cnt(LIST);\n"
                         + two_arm('RAW != 1')) + TOP1)
add('w_indirect_not', sub(POISON + "  localparam int RAW = cnt(LIST);\n"
                          + two_arm('!(RAW <= 1)')) + TOP1)
# OVERRIDE: the default is the refused call, the instance supplies a literal.
add('w_override_val', """package gp;
  function automatic int pcnt(bit [7:0][15:0] l);
    int r;
    r = 0;
    for (int i = 0;i < 8;++i) begin
      r += ((l[i] != 0) ? 1 : 0);
    end
    return r;
  endfunction
  localparam bit [7:0][15:0] PLIST = '{16'd1,16'd2,16'd3,16'd4,16'd5,16'd6,16'd7,16'd8};
endpackage

""" + sub(two_arm('NEXT > 1'),
          ports='parameter int NEXT = gp::pcnt(gp::PLIST)')
      + "\nmodule top;\n  logic r0;\n  sub #(.NEXT(8)) u0 (.o_result(r0));\nendmodule\n")
# OVERRIDE the other way: default is a literal, the actual is the refused call.
add('w_override_unval', """package gp;
  function automatic int pcnt(bit [7:0][15:0] l);
    int r;
    r = 0;
    for (int i = 0;i < 8;++i) begin
      r += ((l[i] != 0) ? 1 : 0);
    end
    return r;
  endfunction
  localparam bit [7:0][15:0] PLIST = '{16'd1,16'd2,16'd3,16'd4,16'd5,16'd6,16'd7,16'd8};
endpackage

""" + sub(two_arm('NEXT > 1'), ports='parameter int NEXT = 8')
      + "\nmodule top;\n  logic r0;\n"
        "  sub #(.NEXT(gp::pcnt(gp::PLIST))) u0 (.o_result(r0));\nendmodule\n")
add('w_defparam', """package gp;
  function automatic int pcnt(bit [7:0][15:0] l);
    int r;
    r = 0;
    for (int i = 0;i < 8;++i) begin
      r += ((l[i] != 0) ? 1 : 0);
    end
    return r;
  endfunction
  localparam bit [7:0][15:0] PLIST = '{16'd1,16'd2,16'd3,16'd4,16'd5,16'd6,16'd7,16'd8};
endpackage

""" + sub(two_arm('NEXT > 1'),
          ports='parameter int NEXT = gp::pcnt(gp::PLIST)')
      + "\nmodule top;\n  logic r0;\n  sub u0 (.o_result(r0));\n"
        "  defparam u0.NEXT = 8;\nendmodule\n")
# A PACKAGE parameter whose initializer is the refused call, read by the
# generate-if.  The module holds NO parameter with a call -> the r10rgg7 cost
# gate (funcParamCallSeen9, set only from module definitions) cannot fire.
add('w_pkgparam_nogate', """package gp;
  function automatic int pcnt(bit [7:0][15:0] l);
    int r;
    r = 0;
    for (int i = 0;i < 8;++i) begin
      r += ((l[i] != 0) ? 1 : 0);
    end
    return r;
  endfunction
  localparam bit [7:0][15:0] PLIST = '{16'd1,16'd2,16'd3,16'd4,16'd5,16'd6,16'd7,16'd8};
  localparam int PRAW = pcnt(PLIST);
endpackage

""" + sub("  import gp::*;\n" + two_arm('PRAW > 1')) + TOP1)
# Same, but a module parameter DOES call a function, so the gate is open.
add('w_pkgparam_gate', """package gp;
  function automatic int pcnt(bit [7:0][15:0] l);
    int r;
    r = 0;
    for (int i = 0;i < 8;++i) begin
      r += ((l[i] != 0) ? 1 : 0);
    end
    return r;
  endfunction
  localparam bit [7:0][15:0] PLIST = '{16'd1,16'd2,16'd3,16'd4,16'd5,16'd6,16'd7,16'd8};
  localparam int PRAW = pcnt(PLIST);
endpackage

""" + sub("  import gp::*;\n" + FOLD
          + "  localparam int OPEN = addup(4);\n"
          "  logic dummy;\n  always_comb dummy = (OPEN != 0);\n"
          + two_arm('PRAW > 1')) + TOP1)
# A $unit-scope parameter whose initializer is the refused call.
add('w_unitparam', """function automatic int ucnt(bit [7:0][15:0] l);
  int r;
  r = 0;
  for (int i = 0;i < 8;++i) begin
    r += ((l[i] != 0) ? 1 : 0);
  end
  return r;
endfunction
localparam bit [7:0][15:0] ULIST = '{16'd1,16'd2,16'd3,16'd4,16'd5,16'd6,16'd7,16'd8};
localparam int URAW = ucnt(ULIST);

""" + sub(two_arm('URAW > 1')) + TOP1)

# ------------------------------------------------- X: CHAIN / LOOP STRUCTURES
add('x_elseif', sub(POISON + "  localparam int RAW = cnt(LIST);\n" + """  generate
    if (RAW > 100) begin : g_reduce
""" + arm('a_mark') + """    end
    else if (RAW > 1) begin : g_reduce
""" + arm('b_mark') + """    end
    else begin : g_reduce
""" + arm('c_mark') + """    end
  endgenerate
""") + TOP1)
# else-less chain, one arm.
add('x_noelse', sub(POISON + "  localparam int RAW = cnt(LIST);\n" + """  generate
    if (RAW > 1) begin : g_reduce
""" + arm('a_mark') + """    end
  endgenerate
""") + TOP1)
# only ONE of the two conditions is unvaluable, and the VALUED one is TRUE.
add('x_mixed_chain', sub(POISON + "  localparam int RAW = cnt(LIST);\n" + """  generate
    if (RAW > 1) begin : g_reduce
""" + arm('a_mark') + """    end
    else if (N > 1) begin : g_reduce
""" + arm('b_mark') + """    end
    else begin : g_reduce
""" + arm('c_mark') + """    end
  endgenerate
""") + TOP1)
# a nested generate-if inside the ELSE arm, on a VALUED condition.
add('x_nested', sub(POISON + "  localparam int RAW = cnt(LIST);\n" + """  generate
    if (RAW > 1) begin : g_reduce
""" + arm('a_mark') + """    end
    else begin : g_reduce
      if (N > 1) begin : g_in
""" + arm('b_mark') + """      end
      else begin : g_in
""" + arm('c_mark') + """      end
    end
  endgenerate
""") + TOP1)
# case-generate on the unvalued parameter.
add('x_casegen', sub(POISON + "  localparam int RAW = cnt(LIST);\n" + """  generate
    case (RAW)
      8: begin : g_reduce
""" + arm('a_mark') + """      end
      default: begin : g_reduce
""" + arm('b_mark') + """      end
    endcase
  endgenerate
""") + TOP1)
# generate-FOR whose bound is the unvalued parameter.
add('x_genfor', sub(POISON + "  localparam int RAW = cnt(LIST);\n" + """  generate
    for (genvar gi = 0; gi < RAW; gi++) begin : g_reduce
""" + arm('a_mark') + """    end
  endgenerate
""") + TOP1)
# generate-for BODY holding a generate-if on the unvalued parameter.
add('x_genfor_body', sub(POISON + "  localparam int RAW = cnt(LIST);\n" + """  generate
    for (genvar gi = 0; gi < 2; gi++) begin : g_loop
      if (RAW > 1) begin : g_reduce
""" + arm('a_mark') + """      end
      else begin : g_reduce
""" + arm('b_mark') + """      end
    end
  endgenerate
""") + TOP1)
# the condition mixes the genvar with the unvalued parameter.
add('x_genfor_genvar', sub(POISON + "  localparam int RAW = cnt(LIST);\n" + """  generate
    for (genvar gi = 0; gi < 2; gi++) begin : g_loop
      if (gi < 1) begin : g_reduce
""" + arm('a_mark') + """      end
      else begin : g_reduce
""" + arm('b_mark') + """      end
    end
  endgenerate
""") + TOP1)

# -------------------------------------------------------------- R: RECURSION
def rec(depth_param):
    return ("""package gp;
  function automatic int pcnt(bit [7:0][15:0] l);
    int r;
    r = 0;
    for (int i = 0;i < 8;++i) begin
      r += ((l[i] != 0) ? 1 : 0);
    end
    return r;
  endfunction
  localparam bit [7:0][15:0] PLIST = '{16'd1,16'd2,16'd3,16'd4,16'd5,16'd6,16'd7,16'd8};
endpackage

module leaf(output logic o);
  always_comb o = 1'b1;
endmodule

module sub #(
  parameter int N = %d
)(
  output logic o_result
);
  localparam int RAW = gp::pcnt(gp::PLIST);
  generate
    if (N > 1) begin : g_reduce
      logic a_mark;
      always_comb begin
        a_mark = 1'b1;
      end
      sub #(.N(N - 1)) u_next (.o_result(o_result));
    end
    else begin : g_reduce
      logic b_mark;
      always_comb begin
        b_mark = 1'b1;
      end
      leaf u_leaf (.o(o_result));
    end
  endgenerate
endmodule

module top;
  logic r0;
  sub #(.N(%d)) u0 (.o_result(r0));
endmodule
""" % (depth_param, depth_param))


# Recursion on a VALUED condition with an unvalued parameter merely PRESENT:
# the chain must keep slang's arm at every depth (a CONTROL for depth 1..4).
for d in (1, 2, 3, 4):
    add('r_valued_d%d' % d, rec(d))


# Recursion driven BY the unvalued parameter: the else arm at every depth.
def rec_unval(depth_param):
    # `(N > 1) && (RAW > 1)`: TWO parameters, only ONE of them unvaluable, and
    # the valued one is what terminates the recursion (a bare `RAW > 1` never
    # terminates and slang rightly rejects it).
    return rec(depth_param).replace('if (N > 1) begin : g_reduce',
                                    'if ((N > 1) && (RAW > 1)) begin : g_reduce')


for d in (2, 4):
    add('r_unval_d%d' % d, rec_unval(d))


def main():
    os.makedirs(CELLS, exist_ok=True)
    for name, text in sorted(CELLS_SRC.items()):
        d = os.path.join(CELLS, name)
        os.makedirs(d, exist_ok=True)
        with open(os.path.join(d, 'dut.sv'), 'w') as f:
            f.write(text)
    print('cells=%d' % len(CELLS_SRC))


main()
