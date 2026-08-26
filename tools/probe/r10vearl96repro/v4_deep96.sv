// r10v96 adversarial arm v4 -- HOMES the pass did not build: a THREE-DEEP
// module chain, an INSTANCE ARRAY, an INTERFACE with a MODPORT carried into a
// submodule, and a BIND instance.  MEASUREMENT ONLY.
package p4d96;
  typedef logic [31:0] d_t;
  localparam d_t DARR [4] = '{ 32'h1, 32'h2, 32'h3, 32'h4 };
endpackage

interface if4d96 import p4d96::*; ();
  localparam d_t IARR [2] = '{ 32'h51, 32'h52 };
  logic [31:0] v;
  assign v = IARR[1] ^ DARR[0];
  modport mp (input v);
endinterface

module leaf4d96 import p4d96::*; (output logic [31:0] o_o);
  localparam d_t LARR [2] = '{ 32'h61, 32'h62 };
  assign o_o = LARR[0] ^ DARR[3];
endmodule

module mid4d96 import p4d96::*; (output logic [31:0] o_o);
  localparam d_t MARR [2] = '{ 32'h71, 32'h72 };
  logic [31:0] l0, l1, l2;
  leaf4d96 u_arr [3] ();                       // INSTANCE ARRAY
  logic [31:0] lo;
  leaf4d96 u_l (.o_o(lo));
  assign o_o = lo ^ MARR[1];
endmodule

module bindee4d96 import p4d96::*; ();
  localparam d_t BARR [2] = '{ 32'h81, 32'h82 };
  logic [31:0] bv;
  assign bv = BARR[0];
endmodule

module top4d96 (output logic [31:0] a_o);
  logic [31:0] m0;
  mid4d96 u_m (.o_o(m0));
  if4d96 u_if ();
  assign a_o = m0 ^ u_if.v;
endmodule

bind mid4d96 bindee4d96 u_bind ();
