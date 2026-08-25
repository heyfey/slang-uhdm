// r10v86 vaB — the TERNARY SHORT-CIRCUIT's own corners: a condition that is a
// PACKAGE parameter (earl85's leaf fold refuses those, so OUR condition stays a
// ref_obj where Surelog's is a constant), a condition that is itself a
// comparison, a condition with a top-bit-set operand, nested ternaries, a
// ternary under the CONCAT fence, and a ternary whose arms differ in kind.
// GOLDEN = Surelog.
package v86t_pkg;
  parameter int TP = 1;
  localparam int TQ = 0;
endpackage
module v86_tn #(parameter int AddrW = 22, parameter int SELP = 1) ();
  import v86t_pkg::*;
  localparam int P = 8;
  localparam int W = 5;

  localparam logic[AddrW-1:0] t_pk1 = ~(('h1 << (TP ? P : W)) - 1'b1);
  localparam logic[AddrW-1:0] t_pk2 = ~(('h1 << (v86t_pkg::TQ ? P : W)) - 1'b1);
  localparam logic[AddrW-1:0] t_cmp = ~(('h1 << ((P > W) ? (P + W) : (P * W))) - 1'b1);
  localparam logic[AddrW-1:0] t_big = ~(('h1 << (((1 << 63) > 5) ? P : W)) - 1'b1);
  localparam logic[AddrW-1:0] t_nst = ~(('h1 << (SELP ? (SELP ? P : W) : (P + W))) - 1'b1);
  localparam logic[AddrW-1:0] t_arm = ~(('h1 << (SELP ? P : ('h1 << W))) - 1'b1);
  localparam logic[AddrW-1:0] t_ar2 = ~(('h1 << (SELP ? ('h1 << W) : P)) - 1'b1);
  localparam logic[AddrW-1:0] t_cat = {('h1 << (SELP ? P : W)), 2'b01};
  localparam logic[AddrW-1:0] t_rep = {2{('h1 << (SELP ? P : W))}};
  localparam logic[AddrW-1:0] t_und = ~(('h1 << ((P > W) ? (P - W) : (P / 0))) - 1'b1);
  localparam logic[AddrW-1:0] t_xr  = ~(('h1 << ((P ^ W) ? P : W)) - 1'b1);
endmodule

module top86_vB ();
  v86_tn #(.AddrW(22), .SELP(1)) i0 ();
  v86_tn #(.AddrW(23), .SELP(0)) i1 ();
endmodule
