#!/usr/bin/env python3
"""r10rgg3 GRID generator — the interface PORT-VIEW member-range law.

Each cell is ONE self-contained dut.sv.  The measured quantity is, for every
interface_inst in the elaborated database, the LEFT range constant of each
parameter-dependent member declaration.  The grid crosses:

  * port form      : modport-qualified / plain / ARRAY (modport) / ARRAY (plain)
  * connection form: named `.p(x)` / positional `(x)` / element `.p(x[0])` /
                     whole-array `.p(arr)`
  * override form  : POSITIONAL `#(8,32,64)` / NAMED `#(.AW(8),...)` / NONE
  * receiving module: HAS a same-named parameter (AW) / has NONE
  * member kinds   : logic var range, wire (net) range, param-typed member,
                     a member whose default chains to another param (VW=BW)
  * MODULE contrast: a module array with a positional override (its own
                     member ranges must follow its own parameters)

Everything is written into ONE file per cell so `surelog -parse -top top` and
`slang-uhdm --single-unit --top top` see identical input.
"""
import os, sys

IFACE = """interface itf #(parameter int AW = 16, parameter int BW = 32,
                parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  wire  [AW-1:0] wn;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a, b, v);
endinterface
"""

def recv(name, params, port, extra=""):
    p = "#(\n  parameter int AW = 5\n)" if params else ""
    return "module %s %s(\n  %s\n);\n%sendmodule\n" % (name, p, port, extra)

CELLS = {}

def cell(name, body):
    CELLS[name] = IFACE + body

# ---- A: modport port, NAMED connection, plain instance, recv WITHOUT AW ----
cell("a1_mp_named_norecvp", recv("recv", False, "itf.mp p") + """
module top;
  itf #(8, 32, 64) inst();
  recv u (.p(inst));
endmodule
""")
# ---- A2: same, recv WITH AW=5 ----
cell("a2_mp_named_recvp", recv("recv", True, "itf.mp p") + """
module top;
  itf #(8, 32, 64) inst();
  recv u (.p(inst));
endmodule
""")
# ---- A3: modport, POSITIONAL connection, recv WITHOUT AW ----
cell("a3_mp_pos_norecvp", recv("recv", False, "itf.mp p") + """
module top;
  itf #(8, 32, 64) inst();
  recv u (inst);
endmodule
""")
# ---- A4: modport, POSITIONAL connection, recv WITH AW ----
cell("a4_mp_pos_recvp", recv("recv", True, "itf.mp p") + """
module top;
  itf #(8, 32, 64) inst();
  recv u (inst);
endmodule
""")
# ---- B: PLAIN (no modport) port ----
cell("b1_pl_named_norecvp", recv("recv", False, "itf p") + """
module top;
  itf #(8, 32, 64) inst();
  recv u (.p(inst));
endmodule
""")
cell("b2_pl_named_recvp", recv("recv", True, "itf p") + """
module top;
  itf #(8, 32, 64) inst();
  recv u (.p(inst));
endmodule
""")
# ---- C: interface ARRAY instance, whole-array port, whole-array connection ----
cell("c1_arr_whole_norecvp", recv("recv", False, "itf.mp p[3]") + """
module top;
  itf #(8, 32, 64) arr[3]();
  recv u (.p(arr));
endmodule
""")
cell("c2_arr_whole_recvp", recv("recv", True, "itf.mp p[3]") + """
module top;
  itf #(8, 32, 64) arr[3]();
  recv u (.p(arr));
endmodule
""")
# ---- D: ARRAY instance, SINGLE port, ELEMENT connection ----
cell("d1_elem_named_norecvp", recv("recv", False, "itf.mp p") + """
module top;
  itf #(8, 32, 64) arr[3]();
  recv u (.p(arr[0]));
endmodule
""")
cell("d2_elem_named_recvp", recv("recv", True, "itf.mp p") + """
module top;
  itf #(8, 32, 64) arr[3]();
  recv u (.p(arr[0]));
endmodule
""")
# ---- E: NAMED override instead of positional (single, modport, named conn) ----
cell("e1_namedovr_norecvp", recv("recv", False, "itf.mp p") + """
module top;
  itf #(.AW(8), .BW(32), .VW(64)) inst();
  recv u (.p(inst));
endmodule
""")
cell("e2_namedovr_recvp", recv("recv", True, "itf.mp p") + """
module top;
  itf #(.AW(8), .BW(32), .VW(64)) inst();
  recv u (.p(inst));
endmodule
""")
cell("e3_namedovr_arr_recvp", recv("recv", True, "itf.mp p[3]") + """
module top;
  itf #(.AW(8), .BW(32), .VW(64)) arr[3]();
  recv u (.p(arr));
endmodule
""")
cell("e4_namedovr_arr_norecvp", recv("recv", False, "itf.mp p[3]") + """
module top;
  itf #(.AW(8), .BW(32), .VW(64)) arr[3]();
  recv u (.p(arr));
endmodule
""")
# ---- F: NO override at all ----
cell("f1_noovr_arr_recvp", recv("recv", True, "itf.mp p[3]") + """
module top;
  itf arr[3]();
  recv u (.p(arr));
endmodule
""")
# ---- G: recv has AW *and* BW, so VW's default chain has a candidate ----
cell("g1_arr_recv_awbw", """module recv #(
  parameter int AW = 5,
  parameter int BW = 64
)(
  itf.mp p[3]
);
endmodule
module top;
  itf #(8, 32, 64) arr[3]();
  recv u (.p(arr));
endmodule
""")
cell("g2_single_recv_awbw", """module recv #(
  parameter int AW = 5,
  parameter int BW = 64
)(
  itf.mp p
);
endmodule
module top;
  itf #(8, 32, 64) inst();
  recv u (.p(inst));
endmodule
""")
# ---- H: two levels of pass-through (Rggen's u_adapter -> u_adapter_common) ----
cell("h1_two_level_arr", """module inner #(
  parameter int AW = 9
)(
  itf.mp p[3]
);
endmodule
module recv #(
  parameter int AW = 5
)(
  itf.mp p[3]
);
  inner #(.AW(AW)) ui (.p(p));
endmodule
module top;
  itf #(8, 32, 64) arr[3]();
  recv #(.AW(7)) u (.p(arr));
endmodule
""")
# ---- I: MODULE contrast — a module array with a positional override ----
cell("i1_module_array_pos", """module leaf #(parameter int AW = 16, parameter int BW = 32)(
  input logic clk
);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
endmodule
module recv #(parameter int AW = 5)(input logic clk);
  leaf #(8, 32) larr[3](.clk(clk));
endmodule
module top;
  logic clk;
  recv #(.AW(7)) u (.clk(clk));
endmodule
""")
# ---- J: RGGEN SHAPE, reduced: array port + named whole-array connection,
#         recv HAS AW (=16 via its own override) and BW but NOT VW ----
cell("j1_rggen_shape", """module recv #(
  parameter int AW = 8,
  parameter int BW = 32
)(
  itf.mp p[25]
);
endmodule
module top;
  itf #(8, 32, 64) arr[25]();
  recv #(.AW(16), .BW(32)) u (.p(arr));
endmodule
""")
# ---- K: RGGEN apb_if SHAPE: single modport port, ELEMENT connection,
#         recv's AW differs from BOTH the instance override and the default ----
cell("k1_rggen_apb_shape", """module recv #(
  parameter int AW = 7
)(
  itf.mp p
);
endmodule
module top;
  itf #(16, 32, 32) arr[2]();
  recv u (.p(arr[1]));
endmodule
""")
# ---- L: single modport port, whole non-array instance, recv AW differs ----
cell("l1_single_recvaw_differs", """module recv #(
  parameter int AW = 7
)(
  itf.mp p
);
endmodule
module top;
  itf #(16, 32, 32) inst();
  recv u (.p(inst));
endmodule
""")
# ---- M: pass a module's own interface PORT down (Rggen block_0 -> u_adapter) --
cell("m1_port_passthrough", """module inner #(
  parameter int AW = 9
)(
  itf.mp p
);
endmodule
module recv #(
  parameter int AW = 7
)(
  itf.mp p
);
  inner #(.AW(AW)) ui (.p(p));
endmodule
module top;
  itf #(16, 32, 32) arr[2]();
  recv u (.p(arr[1]));
endmodule
""")



# ---- N: the SUBSTITUTION's exact scope and transitivity -------------------
# n1 — TRANSITIVITY: interface writes `VW = BW`; the instance and the interface
#      default BOTH say BW=32/VW=32, so a v of [63:0] can ONLY come from
#      re-evaluating `VW = BW` with the RECEIVING module's BW=64.
CELLS["n1_transitive_vw"] = IFACE + """module recv #(
  parameter int BW = 64
)(
  itf.mp p[3]
);
endmodule
module top;
  itf #(8, 32, 32) arr[3]();
  recv u (.p(arr));
endmodule
"""
# n2 — the receiving module's same-named LOCALPARAM (body, not a port param).
CELLS["n2_recv_localparam"] = IFACE + """module recv (
  itf.mp p[3]
);
  localparam int AW = 5;
endmodule
module top;
  itf #(8, 32, 64) arr[3]();
  recv u (.p(arr));
endmodule
"""
# n3 — a same-named VARIABLE in the receiving module must NOT substitute.
CELLS["n3_recv_var_notparam"] = IFACE + """module recv (
  itf.mp p[3]
);
  logic [4:0] AW;
endmodule
module top;
  itf #(8, 32, 64) arr[3]();
  recv u (.p(arr));
endmodule
"""
# n4 — HIERARCHICAL reach: the receiving module has no AW, its PARENT does.
CELLS["n4_parent_has_aw"] = IFACE + """module recv (
  itf.mp p[3]
);
endmodule
module top #(
  parameter int AW = 3
);
  itf #(8, 32, 64) arr[3]();
  recv u (.p(arr));
endmodule
"""
# n5 — the port view under a GEN SCOPE of the receiving module.
CELLS["n5_gen_scope_recv"] = IFACE + """module inner #(
  parameter int AW = 9
)(
  itf.mp p[3]
);
endmodule
module recv #(
  parameter int AW = 6
)(
  itf.mp p[3]
);
  if (1) begin : g
    inner #(.AW(AW)) ui (.p(p));
  end
endmodule
module top;
  itf #(8, 32, 64) arr[3]();
  recv u (.p(arr));
endmodule
"""
# n6 — the receiving module's own param is itself OVERRIDDEN at its
#      instantiation (Rggen's block_0: declared 8, instantiated 16).
CELLS["n6_recv_param_overridden"] = IFACE + """module recv #(
  parameter int AW = 8
)(
  itf.mp p[3]
);
endmodule
module top;
  itf #(8, 32, 64) arr[3]();
  recv #(.AW(16)) u (.p(arr));
endmodule
"""
# n7 — MODULE contrast for the same shape: a module port view does not exist,
#      but a module's OWN member ranges must ignore an enclosing same-named
#      parameter (the law is interface-port-view-only).
CELLS["n7_module_same_named"] = """module leaf #(parameter int AW = 16)(input logic clk);
  logic [AW-1:0] a;
endmodule
module recv #(parameter int AW = 5)(input logic clk);
  leaf larr[3](.clk(clk));
endmodule
module top;
  logic clk;
  recv #(.AW(7)) u (.clk(clk));
endmodule
"""


# n8 — DISAMBIGUATES which value of the receiving module's same-named parameter
#      is used: its DECLARED default (8) or its ELABORATED/overridden value (9).
CELLS["n8_recv_ovr_disambig"] = IFACE + """module recv #(
  parameter int AW = 8
)(
  itf.mp p[3]
);
endmodule
module top;
  itf #(4, 32, 64) arr[3]();
  recv #(.AW(9)) u (.p(arr));
endmodule
"""
# n9 — the receiving module's same-named parameter is a TYPE parameter: it must
#      not be usable as a value and the interface default must survive.
CELLS["n9_recv_type_param"] = IFACE + """module recv #(
  parameter type AW = int
)(
  itf.mp p[3]
);
endmodule
module top;
  itf #(8, 32, 64) arr[3]();
  recv u (.p(arr));
endmodule
"""

# ---- P: MULTI-PARAMETERIZED / TEXT-MULTI defs (the exceptions the emitter
#         already carries) crossed with the ARRAY-element port view ----------
# p1 — TWO distinct override tuples on the same def + array port view, recv HAS AW.
CELLS["p1_multiparam_arr_recvp"] = IFACE + """module recv #(
  parameter int AW = 5
)(
  itf.mp p[3]
);
endmodule
module other;
  itf #(4, 16, 16) o1();
endmodule
module top;
  itf #(8, 32, 64) arr[3]();
  other uo ();
  recv u (.p(arr));
endmodule
"""
# p2 — same, recv has NO AW.
CELLS["p2_multiparam_arr_norecvp"] = IFACE + """module recv (
  itf.mp p[3]
);
endmodule
module other;
  itf #(4, 16, 16) o1();
endmodule
module top;
  itf #(8, 32, 64) arr[3]();
  other uo ();
  recv u (.p(arr));
endmodule
"""
# p3 — multi-param def + SINGLE modport POSITIONAL port view, recv HAS AW.
CELLS["p3_multiparam_pos_recvp"] = IFACE + """module recv #(
  parameter int AW = 5
)(
  itf.mp p
);
endmodule
module other;
  itf #(4, 16, 16) o1();
endmodule
module top;
  itf #(8, 32, 64) inst();
  other uo ();
  recv u (inst);
endmodule
"""
# p4 — TEXT-differing but VALUE-equal overrides (the OneNetRange shape) with an
#      array port view, recv HAS AW.
CELLS["p4_textmulti_arr_recvp"] = IFACE + """module recv #(
  parameter int AW = 5
)(
  itf.mp p[3]
);
endmodule
module other;
  itf #(.AW(8), .BW(32), .VW(64)) o1();
endmodule
module top;
  itf #(8, 32, 64) arr[3]();
  other uo ();
  recv u (.p(arr));
endmodule
"""
# p5 — a GENERATE-bearing interface (the ifaceHasGen9 exception) + array port
#      view, recv HAS AW.
CELLS["p5_gen_iface_arr_recvp"] = """interface itfg #(parameter int AW = 16, parameter int BW = 32,
                 parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  if (1) begin : g
    logic gsig;
  end
  modport mp (input a, b, v);
endinterface
module recv #(
  parameter int AW = 5
)(
  itfg.mp p[3]
);
endmodule
module top;
  itfg #(8, 32, 64) arr[3]();
  recv u (.p(arr));
endmodule
"""

def main():
    root = os.path.dirname(os.path.abspath(__file__))
    for n, txt in sorted(CELLS.items()):
        d = os.path.join(root, n)
        os.makedirs(d, exist_ok=True)
        open(os.path.join(d, 'dut.sv'), 'w').write(txt)
    print("%d cells" % len(CELLS))

if __name__ == '__main__':
    main()