// r10rgg15 grid g1 — an UNSIZED FILL written as a parameter DEFAULT, never
// overridden, over every target type.  One instance.  MEASUREMENT ONLY.
module g1_sub #(
  parameter bit   [7:0] A_b8   = '0,
  parameter bit   [7:0] A_b8o  = '1,
  parameter bit   [7:0] A_b8x  = 'x,
  parameter bit   [7:0] A_b8z  = 'z,
  parameter bit   [7:0] A_b8bb = 'b0,
  parameter bit   [7:0] A_b8hh = 'h0,
  parameter bit   [7:0] A_b8s  = 8'd0,
  parameter bit   [7:0] A_b8l  = 1'b0,
  parameter bit   [7:0] A_b8d  = 0,
  parameter logic [7:0] A_l8   = '0,
  parameter logic [7:0] A_l8o  = '1,
  parameter bit   [1:0] A_b2   = '0,
  parameter bit   [0:0] A_b1r  = '0,
  parameter bit         A_b1   = '0,
  parameter logic       A_l1   = '0,
  parameter int         A_int  = '0,
  parameter int unsigned A_iu  = '0,
  parameter integer     A_intg = '0,
  parameter byte        A_byte = '0,
  parameter             A_unt  = '0,
  parameter      [7:0]  A_ru8  = '0,
  parameter bit  [32:0] A_b33  = '0,
  parameter bit  [64:0] A_b65  = '0,
  parameter bit  [64:0] A_b65o = '1
)();
endmodule

module g1_top;
  g1_sub u1 ();
endmodule
