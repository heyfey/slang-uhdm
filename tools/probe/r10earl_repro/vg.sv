// vg.sv — pass 11, follow-up to vf.sv.  vf proved the DEF-view import copy of a
// NARROW, never-selected, never-qualified struct-pattern package parameter stays
// TAGGED in golden even in a module WITH a parameter port list.  vg varies the
// three package-side triggers (scoped `pkg::` reference, member select, >64-bit
// width) against the same two module shapes, so the module rule can be stated
// without guessing from BlackBePipeInt.
package vgp;
  typedef struct packed {           // 10 bits — NARROW
    logic       req;
    logic       rd;
    logic [7:0] dat;
  } n_t;
  typedef struct packed {           // 96 bits — WIDE
    logic [31:0] a;
    logic [31:0] b;
    logic [31:0] c;
  } w_t;

  parameter n_t N1 = '{req: 1'b0, rd: 1'b0, dat: '0};   // no ref, no select
  parameter n_t N2 = '{req: 1'b1, rd: 1'b0, dat: '0};   // scoped `vgp::N2` read
  parameter n_t N3 = '{req: 1'b0, rd: 1'b1, dat: '0};   // member select N3.req
  parameter w_t W1 = '{a: 32'h0, b: 32'h0, c: 32'h0};   // wide, nothing else
  parameter w_t W2 = '{a: 32'h1, b: 32'h0, c: 32'h0};   // wide + member select
endpackage

// no parameter port list
module vga import vgp::*; (
  input  logic clk_i,
  output vgp::n_t o1, o3,
  output vgp::w_t o4, o5
);
  assign o1 = N1;
  assign o3 = {N3.req, N3.rd, N3.dat};
  assign o4 = W1;
  assign o5 = {W2.a, W2.b, W2.c};
endmodule

// WITH a parameter port list
module vgb import vgp::*; #(
  parameter int Aw = 4
) (
  input  logic clk_i,
  output vgp::n_t o1, o3,
  output vgp::w_t o4, o5
);
  logic [Aw-1:0] unused;
  assign o1 = N1;
  assign o3 = {N3.req, N3.rd, N3.dat};
  assign o4 = W1;
  assign o5 = {W2.a, W2.b, W2.c};
endmodule

module vgtop;
  logic clk;
  vgp::n_t a1, a3, b1, b3;
  vgp::w_t a4, a5, b4, b5;
  vgp::n_t q;
  assign q = vgp::N2;               // the SCOPED reference to N2
  vga u_a (.clk_i(clk), .o1(a1), .o3(a3), .o4(a4), .o5(a5));
  vgb u_b (.clk_i(clk), .o1(b1), .o3(b3), .o4(b4), .o5(b5));
endmodule
