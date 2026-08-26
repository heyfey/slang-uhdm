// r10v96 adversarial arm v9 -- the CONCAT half at every carrier the fixed law
// must still get right: a package CONCAT parameter MATERIALIZED into an
// interface, a submodule and a three-deep chain, beside each carrier's OWN
// concat declaration.  MEASUREMENT ONLY.
package p9c96;
  typedef logic [31:0] z_t;
  localparam z_t PCAT [2] = { 32'h1, 32'h2 };
  localparam z_t PPAT [2] = '{ 32'h3, 32'h4 };
endpackage

interface if9c96 import p9c96::*; ();
  localparam z_t ICAT [2] = { 32'h11, 32'h12 };
  logic [31:0] v;
  assign v = ICAT[0] ^ PCAT[1] ^ PPAT[0];
endinterface

module leaf9c96 import p9c96::*; (output logic [31:0] o_o);
  localparam z_t LCAT [2] = { 32'h21, 32'h22 };
  assign o_o = LCAT[0] ^ PCAT[1];
endmodule

module mid9c96 import p9c96::*; (output logic [31:0] o_o);
  localparam z_t MCAT [2] = { 32'h31, 32'h32 };
  logic [31:0] lv;
  leaf9c96 u_l (.o_o(lv));
  assign o_o = lv ^ MCAT[1] ^ PCAT[0];
endmodule

module top9c96 (output logic [31:0] a_o);
  logic [31:0] mv;
  mid9c96 u_m (.o_o(mv));
  if9c96 u_if ();
  assign a_o = mv ^ u_if.v;
endmodule
