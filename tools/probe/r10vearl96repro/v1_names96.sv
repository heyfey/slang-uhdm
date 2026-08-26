// r10v96 adversarial arm v1 -- NAME COLLISION and SHADOWING.
// Two packages declare the SAME typedef name; one is wildcard-imported and the
// other used scoped in the same module; a third module declares a MODULE-LOCAL
// typedef of the same name shadowing the imported one.  MEASUREMENT ONLY.
package pA1v96;
  typedef logic [31:0] c_t;
  localparam c_t AARR [4] = '{ 32'h1, 32'h2, 32'h3, 32'h4 };
endpackage

package pB1v96;
  typedef logic [15:0] c_t;
  localparam c_t BARR [4] = '{ 16'h5, 16'h6, 16'h7, 16'h8 };
endpackage

module m1both96 import pA1v96::*; (output logic [31:0] o_o);
  localparam c_t MYA [2] = '{ 32'h11, 32'h12 };           // imported c_t
  localparam pB1v96::c_t MYB [2] = '{ 16'h13, 16'h14 };   // scoped OTHER c_t
  assign o_o = MYA[1] ^ AARR[2] ^ {16'h0, MYB[0]} ^ {16'h0, pB1v96::BARR[3]};
endmodule

module m1shadow96 import pA1v96::*; (output logic [31:0] o_o);
  typedef logic [7:0] c_t;                                 // SHADOWS pA1v96::c_t
  localparam c_t SARR [4] = '{ 8'h1, 8'h2, 8'h3, 8'h4 };
  assign o_o = {24'h0, SARR[2]} ^ AARR[1];
endmodule

module top1v96 (output logic [31:0] a_o);
  logic [31:0] x, y;
  m1both96   u_b (.o_o(x));
  m1shadow96 u_s (.o_o(y));
  assign a_o = x ^ y;
endmodule
