#!/usr/bin/env python3
"""r11u23 — generate the golden grid for the UNBOUND half of
`UhdmWriter::writeCont_assign`.

Two faces share ONE producer predicate (`bindVariable(mod, m, lhs->VpiName())`):

  FACE A  `ref->Actual_group(var)` (UhdmWriter.cpp:2165) sits INSIDE
          `if (var) { ... }` — so an UNBOUND cont_assign Lhs ref_obj carries
          NO `vpiActual` at all, whatever the Rhs is.
  FACE B  the trailing `if (simplified == false)` arm (UhdmWriter.cpp:2243)
          folds the Rhs for ANY Lhs shape and installs the result ONLY when it
          is a CONSTANT, with `tps` null so `adjustSize` returns at once.

Arms are written to $GRID (default /tmp/r11u23_grid) and copied into
grid/ for the commit.  Every arm's rc is recorded by run23.sh.
"""
import os, sys, shutil

OUT = sys.argv[1] if len(sys.argv) > 1 else '/tmp/r11u23_grid'

PK = """package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
"""

ARMS = {}


def arm(name, text):
    ARMS[name] = text


# ---------------------------------------------------------------------------
# A — RE-MEASUREMENT of the nine arms r11u22 committed for its R0, verbatim
#     (a01..a10 are byte-for-byte copies of r11u22repro/grid/{c01,c02,c05,
#     c06,c07,c15,a07,a08,c03,c16}/dut.sv), plus the u2r witness.
# ---------------------------------------------------------------------------
arm('a01_genlocal_fill0', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
    assign o2 = lv;
  end
endmodule
""")

arm('a02_genlocal_sized', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = (P != PNone) ? ~(32'hffff_ffff << s) : 32'd5;
    assign o2 = lv;
  end
endmodule
""")

arm('a03_bitsel_lhs', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : gb
    assign o2[0] = (P != PNone) ? a[0] : '0;
  end
endmodule
""")

arm('a04_concat_lhs', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2, output logic [31:0] o3);
  if (1) begin : gb
    assign {o2, o3} = (P != PNone) ? {a, a} : '0;
  end
endmodule
""")

arm('a05_member_lhs', PK + """package sp;
  typedef struct packed { logic [31:0] m; } st_t;
endpackage
module top import pk::*; import sp::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output st_t o2);
  if (1) begin : gb
    assign o2.m = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
  end
endmodule
""")

arm('a06_outer_genscope_decl', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : g1
    logic [31:0] ov;
    assign o2 = ov;
    if (1) begin : g2
      assign ov = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
    end
  end
endmodule
""")

arm('a07_iface_genif_fill0', PK + """interface ifc import pk::*; #(parameter p_e P = PNone) (input logic [4:0] s);
  logic [31:0] o2;
  if (1) begin : gb
    assign o2 = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
  end
endinterface
module top (input logic [4:0] s);
  ifc u1 (.s(s));
endmodule
""")

arm('a08_iface_mod_fill0', PK + """interface ifc import pk::*; #(parameter p_e P = PNone) (input logic [4:0] s);
  logic [31:0] o2;
  assign o2 = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
endinterface
module top (input logic [4:0] s);
  ifc u1 (.s(s));
endmodule
""")

arm('a09_genlocal_namesake', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  logic [3:0] lv;
  assign o2 = {28'd0, lv};
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
  end
endmodule
""")

arm('a10_bare_var_lhs', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  var bv;
  assign o2 = {31'd0, bv};
  if (1) begin : gb
    assign bv = (P != PNone) ? s[0] : '0;
  end
endmodule
""")

arm('a11_u2r_witness', """module w11 #(parameter int NumIn = 4, parameter bit ExtPrio = 1'b0)
  (input logic clk_i, input logic rst_ni, input logic flush_i,
   input logic [NumIn-1:0] req_i, input logic gnt_i,
   input logic [$clog2(NumIn)-1:0] rr_i, output logic [$clog2(NumIn)-1:0] rr_o);
  localparam int IdxW = $clog2(NumIn);
  if (NumIn > 1) begin : gen_arbiter
    logic [IdxW-1:0] rr_q;
    if (ExtPrio) begin : gen_ext_rr
      assign rr_q = rr_i;
    end else begin : gen_int_rr
      logic [IdxW-1:0] rr_d;
      assign rr_d = (gnt_i && |req_i) ?
                    ((rr_q == IdxW'(NumIn-1)) ? '0 : rr_q + 1'b1) : rr_q;
      always_ff @(posedge clk_i or negedge rst_ni) begin : p_rr_regs
        if (!rst_ni)      rr_q <= '0;
        else if (flush_i) rr_q <= '0;
        else              rr_q <= rr_d;
      end
    end
    assign rr_o = rr_q;
  end
endmodule
""")

# ---------------------------------------------------------------------------
# B — FACE A: the Lhs ref_obj's `vpiActual`, Lhs HOME x Rhs KIND.
#     `bindVariable` searches the enclosing module_inst's Nets + Variables ONLY.
# ---------------------------------------------------------------------------
BHEAD = """module top (input logic [31:0] a, input logic [4:0] s,
            output logic [31:0] o2, output logic [31:0] o3);
"""


def b(name, body, extra=''):
    arm(name, extra + BHEAD + body + "endmodule\n")


b('b01_genlocal_rhs_wholeref', """  if (1) begin : gb
    logic [31:0] lv;
    assign lv = a;
    assign o2 = lv;
  end
""")
b('b02_genlocal_rhs_op', """  if (1) begin : gb
    logic [31:0] lv;
    assign lv = a & 32'hff;
    assign o2 = lv;
  end
""")
b('b03_genlocal_rhs_literal', """  if (1) begin : gb
    logic [31:0] lv;
    assign lv = 32'd7;
    assign o2 = lv;
  end
""")
b('b04_genlocal_rhs_bitsel', """  if (1) begin : gb
    logic [31:0] lv;
    assign lv = {31'd0, a[0]};
    assign o2 = lv;
  end
""")
b('b05_genlocal_rhs_hierpath', """  if (1) begin : gb
    logic [31:0] lv;
    assign lv = u1.iv;
    assign o2 = lv;
  end
  sub u1 (.a(a));
""", """module sub (input logic [31:0] a);
  logic [31:0] iv;
  assign iv = a;
endmodule
""")
b('b06_genlocal_rhs_tern', """  if (1) begin : gb
    logic [31:0] lv;
    assign lv = (1) ? a : 32'd0;
    assign o2 = lv;
  end
""")
b('b07_ancestor_genlocal_lhs', """  if (1) begin : g1
    logic [31:0] ov;
    assign o2 = ov;
    if (1) begin : g2
      assign ov = a & 32'hff;
    end
  end
""")
b('b08_genlocal_net_lhs', """  if (1) begin : gb
    wire [31:0] lw;
    assign lw = a & 32'hff;
    assign o2 = lw;
  end
""")
b('b09_modulenet_lhs', """  wire [31:0] mw;
  assign o2 = mw;
  if (1) begin : gb
    assign mw = a & 32'hff;
  end
""")
b('b10_modulevar_lhs', """  logic [31:0] mv;
  assign o2 = mv;
  if (1) begin : gb
    assign mv = a & 32'hff;
  end
""")
b('b11_port_lhs', """  if (1) begin : gb
    assign o2 = a & 32'hff;
  end
""")
b('b12_genlocal_namesake_bind', """  logic [31:0] nv;
  assign o3 = nv;
  if (1) begin : gb
    logic [31:0] nv;
    assign nv = a & 32'hff;
    assign o2 = nv;
  end
""")
b('b13_genfor_genlocal', """  for (genvar g = 0; g < 2; g++) begin : gf
    logic [31:0] fv;
    assign fv = a & 32'hff;
  end
  assign o2 = gf[0].fv;
""")
b('b14_unnamed_genblk_genlocal', """  if (1) begin
    logic [31:0] uv;
    assign uv = a & 32'hff;
  end
  assign o2 = a;
""")
b('b17_genlocal_rhs_constcall', """  function automatic int f7(); return 7; endfunction
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = f7();
    assign o2 = lv;
  end
""")
b('b18_nested3_genlocal', """  if (1) begin : g1
    if (1) begin : g2
      if (1) begin : g3
        logic [31:0] nv;
        assign nv = a & 32'hff;
      end
    end
  end
  assign o2 = a;
""")
b('b19_genlocal_rhs_genlocal', """  if (1) begin : gb
    logic [31:0] lv;
    logic [31:0] mv2;
    assign mv2 = a;
    assign lv = mv2;
    assign o2 = lv;
  end
""")
b('b20_gencase_genlocal', """  case (1)
    1: begin : gc
      logic [31:0] cv;
      assign cv = a & 32'hff;
    end
  endcase
  assign o2 = a;
""")

arm('b15_iface_genscope_actual', PK + """interface ifc (input logic [31:0] a);
  logic [31:0] o2;
  if (1) begin : gb
    assign o2 = a & 32'hff;
  end
endinterface
module top (input logic [31:0] a);
  ifc u1 (.a(a));
endmodule
""")
arm('b16_iface_modscope_actual', PK + """interface ifc (input logic [31:0] a);
  logic [31:0] o2;
  assign o2 = a & 32'hff;
endinterface
module top (input logic [31:0] a);
  ifc u1 (.a(a));
endmodule
""")

# ---------------------------------------------------------------------------
# C — FACE B: the OUTCOMES of the trailing arm, on an UNBOUND gen-local Lhs.
# ---------------------------------------------------------------------------
CHEAD = PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
"""


def c(name, decl, expr_, extra=''):
    arm(name, (extra or CHEAD) + """  if (1) begin : gb
    %s lv;
    assign lv = (P != PNone) ? ~(32'hffff_ffff << s) : %s;
    assign o2 = %s;
  end
endmodule
""" % (decl, expr_, 'lv' if decl.startswith('logic [31:0]') else "32'd0"))


c('c01_fill0', "logic [31:0]", "'0")
c('c02_fill1', "logic [31:0]", "'1")
c('c03_fillx', "logic [31:0]", "'x")
c('c04_fillz', "logic [31:0]", "'z")
c('c05_sized32', "logic [31:0]", "32'd5")
c('c06_sized1', "logic [31:0]", "{31'd0, 1'b0}")
c('c07_paramref', "logic [31:0]", "K")
c('c08_clog2', "logic [31:0]", "$clog2(33)")
c('c09_enumref', "logic [31:0]", "PBal")
c('c10_constop', "logic [31:0]", "32'd2 + 32'd3")
c('c11_concat', "logic [31:0]", "{16'd1, 16'd2}")
c('c12_negative', "logic [31:0]", "32'd2 - 32'd3")
c('c14_xor_arm', "logic [31:0]", "32'hf0 ^ 32'h0f")
c('c15_caseeq_arm', "logic [31:0]", "{31'd0, 32'd1 === 32'd1}")
c('c16_countones_arm', "logic [31:0]", "$countones(32'hff)")
c('c17_bitsel_arm', "logic [31:0]", "{31'd0, a[0]}")
c('c18_inner_tern_arm', "logic [31:0]", "(s[0]) ? 32'd1 : 32'd2")
c('c20_xconst_arm', "logic [31:0]", "32'bx")
c('c22_string_arm', "logic [31:0]", "\"AB\"")
c('c23_baresig_arm', "logic [31:0]", "a")
c('c25_cast_arm', "logic [31:0]", "int'(7)")
c('c26_repl_arm', "logic [31:0]", "{4{8'h0f}}")
c('c27_inside_arm', "logic [31:0]", "{31'd0, 32'd3 inside {32'd1, 32'd3}}")
c('c28_power_arm', "logic [31:0]", "32'd2 ** 32'd3")
c('c30_bits_arm', "logic [31:0]", "$bits(a)")

# the parameter K that c07 reads
ARMS['c07_paramref'] = ARMS['c07_paramref'].replace(
    "#(parameter p_e P = PNone)", "#(parameter p_e P = PNone, parameter int K = 9)")

arm('c13_64bit_arm', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [63:0] o2);
  if (1) begin : gb
    logic [63:0] lv;
    assign lv = (P != PNone) ? {a, a} : 64'hffff_ffff_ffff_ffff;
    assign o2 = lv;
  end
endmodule
""")
arm('c19_wide_arm', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [71:0] o2);
  if (1) begin : gb
    logic [71:0] lv;
    assign lv = (P != PNone) ? {a, a, 8'd0} : 72'h1_0000_0000_0000_0000;
    assign o2 = lv;
  end
endmodule
""")
arm('c21_real_arm', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : gb
    real lv;
    assign lv = (P != PNone) ? 2.5 : 1.5;
  end
  assign o2 = a;
endmodule
""")
arm('c24_hierpath_arm', PK + """module sub (input logic [31:0] a);
  logic [31:0] iv;
  assign iv = a;
endmodule
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  sub u1 (.a(a));
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = (P != PNone) ? ~(32'hffff_ffff << s) : u1.iv;
    assign o2 = lv;
  end
endmodule
""")
arm('c29_userfunc_arm', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  function automatic int f4(); return 4; endfunction
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = (P != PNone) ? ~(32'hffff_ffff << s) : f4();
    assign o2 = lv;
  end
endmodule
""")

# ---------------------------------------------------------------------------
# D — SCOPES, on the fold face with a gen-local Lhs and a '0 fill arm.
# ---------------------------------------------------------------------------
arm('d01_genif_else', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (0) begin : gb0
    assign o2 = a;
  end else begin : gb1
    logic [31:0] lv;
    assign lv = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
    assign o2 = lv;
  end
endmodule
""")
arm('d02_genfor', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  for (genvar g = 0; g < 2; g++) begin : gf
    logic [31:0] lv;
    assign lv = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
  end
  assign o2 = gf[0].lv;
endmodule
""")
arm('d03_nested3', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : g1
    if (1) begin : g2
      if (1) begin : g3
        logic [31:0] lv;
        assign lv = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
      end
    end
  end
  assign o2 = a;
endmodule
""")
arm('d04_gencase', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  case (1)
    1: begin : gc
      logic [31:0] lv;
      assign lv = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
    end
  endcase
  assign o2 = a;
endmodule
""")
arm('d05_genif_in_genfor', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  for (genvar g = 0; g < 2; g++) begin : gf
    if (1) begin : gi
      logic [31:0] lv;
      assign lv = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
    end
  end
  assign o2 = a;
endmodule
""")
arm('d06_child_instance', PK + """module sub import pk::*; #(parameter p_e P = PNone) (input logic [4:0] s);
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
  end
endmodule
module top (input logic [4:0] s, output logic [31:0] o2);
  sub u1 (.s(s));
  assign o2 = 32'd0;
endmodule
""")
arm('d07_unnamed_genblk', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin
    logic [31:0] lv;
    assign lv = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
  end
  assign o2 = a;
endmodule
""")
arm('d09_two_instances', PK + """module sub import pk::*; #(parameter p_e P = PNone) (input logic [4:0] s);
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
  end
endmodule
module top (input logic [4:0] s, output logic [31:0] o2);
  sub #(.P(pk::PNone)) u1 (.s(s));
  sub #(.P(pk::PBal))  u2 (.s(s));
  assign o2 = 32'd0;
endmodule
""")
arm('d10_comma_list', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : gb
    logic [31:0] lv, lw;
    assign lv = (P != PNone) ? ~(32'hffff_ffff << s) : '0,
           lw = (P != PNone) ? ~(32'hffff_ffff << s) : 32'd5;
  end
  assign o2 = a;
endmodule
""")
arm('d11_unpacked_elem_lhs', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  logic [31:0] arr [0:1];
  for (genvar g = 0; g < 2; g++) begin : gf
    assign arr[g] = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
  end
  assign o2 = arr[0];
endmodule
""")
arm('d12_partsel_lhs', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : gb
    assign o2[7:0] = (P != PNone) ? a[7:0] : '0;
  end
  assign o2[31:8] = 24'd0;
endmodule
""")

# ---------------------------------------------------------------------------
# E — the CONDITION and the OPERAND GATE, on the unbound half.
# ---------------------------------------------------------------------------
arm('e01_signal_cond', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = (s[0]) ? ~(32'hffff_ffff << s) : '0;
    assign o2 = lv;
  end
endmodule
""")
arm('e02_genvar_cond', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  for (genvar g = 0; g < 2; g++) begin : gf
    logic [31:0] lv;
    assign lv = (g == 0) ? ~(32'hffff_ffff << s) : '0;
  end
  assign o2 = a;
endmodule
""")
arm('e03_genlocalparam_cond', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : gb
    localparam int Q = 1;
    logic [31:0] lv;
    assign lv = (Q == 1) ? '0 : ~(32'hffff_ffff << s);
    assign o2 = lv;
  end
endmodule
""")
arm('e04_untaken_baresig', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = (P == PNone) ? '0 : a;
    assign o2 = lv;
  end
endmodule
""")
arm('e05_untaken_bare_partsel', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : gb
    logic [7:0] lv;
    assign lv = (P == PNone) ? 8'd5 : a[7:0];
    assign o2 = {24'd0, lv};
  end
endmodule
""")
arm('e06_untaken_idxpartsel_in_op', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = (P == PNone) ? 32'd5 : {24'd0, a[s +: 8]};
    assign o2 = lv;
  end
endmodule
""")
arm('e07_fill_cond', PK + """module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = ('1) ? 32'd5 : ~(32'hffff_ffff << s);
    assign o2 = lv;
  end
endmodule
""")


# ---------------------------------------------------------------------------
# F — THE CLONE, isolated.  `writeCont_assign` clones the WHOLE cont_assign
# (and therefore mints a FRESH Lhs ref_obj that `lateBinding` can never see,
# because `mod->getLateBinding()` holds the ORIGINALS) in two places reachable
# with an UNBOUND Lhs:
#     * the trailing arm, when `reduceExpr` produced a CONSTANT (:2264);
#     * `DetectUnsizedConstant`, when ANY constant in the Rhs tree has
#       `VpiSize() == -1` (:2288).
# These arms separate the two from the Rhs KIND and from the ternary.
# ---------------------------------------------------------------------------
FHEAD = """module top #(parameter int K = 9)
  (input logic [31:0] a, input logic [4:0] s,
   output logic [31:0] o2, output logic [31:0] o3);
"""


def f(name, body, extra=''):
    arm(name, extra + FHEAD + body + "endmodule\n")


f('f01_genlocal_rhs_bare_fill', """  if (1) begin : gb
    logic [31:0] lv;
    assign lv = '0;
    assign o2 = lv;
  end
""")
f('f02_genlocal_rhs_unsized_in_op', """  if (1) begin : gb
    logic [31:0] lv;
    assign lv = a | '0;
    assign o2 = lv;
  end
""")
f('f06_genlocal_rhs_paramref', """  if (1) begin : gb
    logic [31:0] lv;
    assign lv = K;
    assign o2 = lv;
  end
""")
f('f07_genlocal_rhs_constop', """  if (1) begin : gb
    logic [31:0] lv;
    assign lv = 32'd2 + 32'd3;
    assign o2 = lv;
  end
""")
f('f08_genlocal_rhs_clog2', """  if (1) begin : gb
    logic [31:0] lv;
    assign lv = $clog2(33);
    assign o2 = lv;
  end
""")
f('f09_genlocal_net_rhs_fill', """  if (1) begin : gb
    wire [31:0] lw;
    assign lw = '0;
    assign o2 = lw;
  end
""")
f('f10_genlocal_rhs_fill_in_concat', """  if (1) begin : gb
    logic [63:0] lv;
    assign lv = {a, '0};
    assign o2 = lv[31:0];
  end
""")
f('f11_modulenet_rhs_fill', """  wire [31:0] mw;
  assign o2 = mw;
  if (1) begin : gb
    assign mw = '0;
  end
""")
f('f12_modulenet_tern_fold', """  wire [31:0] mw;
  assign o2 = mw;
  if (1) begin : gb
    assign mw = (K == 9) ? '0 : a;
  end
""")
f('f13_genlocal_rhs_unknown_fill', """  if (1) begin : gb
    logic [31:0] lv;
    assign lv = a ^ 'x;
    assign o2 = lv;
  end
""")
f('f14_ancestor_genlocal_rhs_fill', """  if (1) begin : g1
    logic [31:0] ov;
    assign o2 = ov;
    if (1) begin : g2
      assign ov = '0;
    end
  end
""")
f('f17_genlocal_rhs_string', """  if (1) begin : gb
    logic [31:0] lv;
    assign lv = "AB";
    assign o2 = lv;
  end
""")
f('f18_genlocal_rhs_partsel', """  if (1) begin : gb
    logic [31:0] lv;
    assign lv = {24'd0, a[7:0]};
    assign o2 = lv;
  end
""")
f('f19_genlocal_rhs_pattern', """  if (1) begin : gb
    logic [31:0] lv;
    assign lv = '{default: '0};
    assign o2 = lv;
  end
""")
f('f20_genlocal_rhs_bare_partsel', """  if (1) begin : gb
    logic [7:0] lv;
    assign lv = a[7:0];
    assign o2 = {24'd0, lv};
  end
""")
f('f21_genlocal_rhs_sysfunc_unlisted', """  if (1) begin : gb
    logic [31:0] lv;
    assign lv = $countones(32'hff);
    assign o2 = lv;
  end
""")
f('f22_genlocal_rhs_xor', """  if (1) begin : gb
    logic [31:0] lv;
    assign lv = 32'hf0 ^ 32'h0f;
    assign o2 = lv;
  end
""")
f('f23_genlocal_delayed_fill', """  if (1) begin : gb
    wire [31:0] lw;
    assign #1 lw = '0;
    assign o2 = lw;
  end
""")
f('f24_genlocal_two_cells_one_folds', """  if (1) begin : gb
    logic [31:0] lv, lw;
    assign lv = '0;
    assign lw = a & 32'hff;
    assign o2 = lv ^ lw;
  end
""")

# ---------------------------------------------------------------------------
# G — what OUR emitter mints for each fill literal in a gen-scope cont_assign,
#     beside what Surelog mints.  The unbound fold hands the arm BACK and
#     `adjustSize(tps == nullptr)` returns at once, so golden's object is the
#     RAW literal at `VpiSize` -1; these arms read both sides of that object
#     with no ternary in the way.
# ---------------------------------------------------------------------------
for _n, _v in (('g01', "'0"), ('g02', "'1"), ('g03', "'x"), ('g04', "'z")):
    arm(_n + '_barefill_' + _v[1:], """module top (input logic [31:0] a, output logic [31:0] o2);
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = %s;
    assign o2 = lv;
  end
endmodule
""" % _v)

# ---------------------------------------------------------------------------
# H — THE CONCAT FENCE.  `ExprEval::reduceExpr`'s `vpiConcatOp` arm
# (`ExprEval.cpp:3993-4146`) walks the operands and, for a `vpiIntConst` or
# `vpiUIntConst` operand, does
#       if (operands.size() == 1 || (size != 64)) { …append the bits… }
#       else { c1 = nullptr; }
# and EVERY arithmetic / comparison / reduction / inside arm of `reduceExpr`
# mints its result at `VpiSize(64)` (36 sites).  So a multi-operand concat one
# of whose operands REDUCES is killed by its own reduce, and golden keeps the
# whole ternary.  These arms separate that from the operand kinds that do fold.
# ---------------------------------------------------------------------------
HHEAD = PK + """module top import pk::*; #(parameter p_e P = PNone, parameter int K = 9)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
"""


def h(name, expr_):
    arm(name, HHEAD + """  if (1) begin : gb
    logic [31:0] lv;
    assign lv = (P != PNone) ? ~(32'hffff_ffff << s) : %s;
    assign o2 = lv;
  end
endmodule
""" % expr_)


h('h01_concat_param_operand', "{16'd0, K[15:0]}")
h('h02_bare_inside_arm', "{31'd0, 32'd3 inside {32'd1, 32'd3}}")
h('h03_concat_op_operand', "{16'd0, 16'd1 + 16'd2}")
h('h04_concat_single_operand', "{32'd5}")
h('h05_nested_concat', "{16'd0, {8'd1, 8'd2}}")
h('h06_multiconcat_op_operand', "{4{8'd1 + 8'd2}}")
h('h07_pure_inside_arm', "32'd3 inside {32'd1, 32'd3}")
h('h08_concat_paramref_whole', "{K, K}")
h('h09_concat_clog2_operand', "{16'd0, 16'($clog2(33))}")
h('h10_concat_enum_operand', "{16'd0, 16'(PBal)}")

if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    for n, t in sorted(ARMS.items()):
        d = os.path.join(OUT, n)
        os.makedirs(d, exist_ok=True)
        with open(os.path.join(d, 'dut.sv'), 'w') as f:
            f.write(t)
    print("arms=%d out=%s" % (len(ARMS), OUT))
