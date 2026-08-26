// r10earl96 arm g2 — IMPORT FORMS over the head shape: the SAME package
// unpacked-array-of-typedef parameter reached by a WILDCARD import, an
// EXPLICIT single-name import, a SCOPED use with no import at all, and a
// $unit-scope import.  MEASUREMENT ONLY.
package p2f96;
  typedef logic [31:0] w_t;
  localparam w_t WILD [4] = '{ 32'h1, 32'h2, 32'h3, 32'h4 };
  localparam w_t EXPL [4] = '{ 32'h5, 32'h6, 32'h7, 32'h8 };
  localparam w_t SCOP [4] = '{ 32'h9, 32'ha, 32'hb, 32'hc };
  localparam w_t UNIT [4] = '{ 32'hd, 32'he, 32'hf, 32'h10 };
endpackage

import p2f96::UNIT;                     // $unit-scope explicit import

module m2wild96 import p2f96::*;  (output logic [31:0] o_o);
  assign o_o = WILD[2];
endmodule

module m2expl96 import p2f96::EXPL; (output logic [31:0] o_o);
  assign o_o = EXPL[2];
endmodule

module m2scop96 (output logic [31:0] o_o);
  assign o_o = p2f96::SCOP[2];
endmodule

module m2unit96 (output logic [31:0] o_o);
  assign o_o = UNIT[2];
endmodule

module top2f96 (output logic [31:0] a_o);
  logic [31:0] w, e, s, u;
  m2wild96 u_w (.o_o(w));
  m2expl96 u_e (.o_o(e));
  m2scop96 u_s (.o_o(s));
  m2unit96 u_u (.o_o(u));
  assign a_o = w ^ e ^ s ^ u;
endmodule
