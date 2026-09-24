// r10earl62 GRID A — MODULE-LOCAL enum constant references in a PARAMETERIZED
// module, read in every carrier the Earlgrey head touches, beside the two
// controls that separate the candidate discriminators:
//   * a PACKAGE enum (one symbol for every specialization)  -> control
//   * a NON-parameterized module with the same local typedef -> control
// LHS is always golden.
package p62;
  typedef enum logic [1:0] { PkgA, PkgB, PkgC } pkg_op_e;
endpackage

module m62 #(parameter int W = 8) (
  input  logic        clk,
  input  logic [W-1:0] din,
  output logic [W-1:0] dout,
  output logic        f_plain,
  output logic        f_pat_direct,
  output logic        f_pat_cond,
  output logic        f_pkg,
  output logic        f_gen,
  output logic        f_proc
);
  import p62::*;
  // MODULE-LOCAL enum typedef: one EnumValueSymbol PER SPECIALIZATION.
  typedef enum logic [1:0] { LocA, LocB, LocC } loc_op_e;
  typedef struct packed {
    loc_op_e     op;
    logic        err;
    logic [1:0]  sz;
  } loc_t;

  loc_op_e  cur;
  loc_t     rec;
  pkg_op_e  pcur;

  struct packed { logic a; logic b; } pk;

  // (1) PLAIN cont_assign RHS
  assign f_plain = (cur == LocB);
  // (2) assignment-pattern member value, DIRECT
  assign pk = '{ a: (cur == LocB), b: 1'b0 };
  assign f_pat_direct = pk.a;
  // (3) assignment-pattern member value, TERNARY CONDITION
  assign f_pat_cond = ((cur != LocB) ? 1'b1 : 1'b0);
  // (4) PACKAGE enum control, same carriers
  assign f_pkg = (pcur == PkgB);
  // (5) struct member select of a MODULE-LOCAL typedef'd struct variable
  assign dout = { {(W-2){1'b0}}, rec.sz };
  // (6) procedural read
  always_comb begin
    f_proc = (cur == LocC) | rec.err;
  end
  // (7) gen scope
  generate
    if (W > 4) begin : gblk
      assign f_gen = (cur == LocA);
    end else begin : gblk
      assign f_gen = 1'b0;
    end
  endgenerate
endmodule

module m62_np (
  input  logic clk,
  output logic f_plain
);
  typedef enum logic [1:0] { NpA, NpB, NpC } np_op_e;
  np_op_e ncur;
  assign f_plain = (ncur == NpB);
endmodule

module top62 (input logic clk, output logic [15:0] o);
  logic [7:0]  d8;
  logic [15:0] d16;
  logic a1,a2,a3,a4,a5,a6, b1,b2,b3,b4,b5,b6, c1;
  // TWO DIFFERENT SPECIALIZATIONS of m62 + one repeat of the FIRST
  m62 #(.W(8))  u_a (.clk(clk), .din(8'h0),  .dout(d8),  .f_plain(a1),
                     .f_pat_direct(a2), .f_pat_cond(a3), .f_pkg(a4),
                     .f_gen(a5), .f_proc(a6));
  m62 #(.W(16)) u_b (.clk(clk), .din(16'h0), .dout(d16), .f_plain(b1),
                     .f_pat_direct(b2), .f_pat_cond(b3), .f_pkg(b4),
                     .f_gen(b5), .f_proc(b6));
  m62_np u_c (.clk(clk), .f_plain(c1));
  assign o = d16;
endmodule
