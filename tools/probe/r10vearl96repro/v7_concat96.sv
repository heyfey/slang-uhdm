// r10v96 adversarial arm v7 -- THE CONCAT DISTINGUISHER.  The SAME imported
// package typedef used for an unpacked-array parameter initialised by an
// ASSIGNMENT PATTERN and by a CONCATENATION, side by side, under a wildcard
// import, an explicit import and a scoped use.  MEASUREMENT ONLY.
package p7x96;
  typedef logic [31:0] x_t;
  localparam x_t PKGPAT [2] = '{ 32'h1, 32'h2 };
  localparam x_t PKGCAT [2] = { 32'h3, 32'h4 };
endpackage

module m7wild96 import p7x96::*; (output logic [31:0] o_o);
  localparam x_t WPAT [2] = '{ 32'h11, 32'h12 };
  localparam x_t WCAT [2] = { 32'h13, 32'h14 };
  assign o_o = WPAT[0] ^ WCAT[1] ^ PKGPAT[0] ^ PKGCAT[1];
endmodule

module m7expl96 import p7x96::x_t; (output logic [31:0] o_o);
  localparam x_t EPAT [2] = '{ 32'h21, 32'h22 };
  localparam x_t ECAT [2] = { 32'h23, 32'h24 };
  assign o_o = EPAT[0] ^ ECAT[1];
endmodule

module m7scop96 (output logic [31:0] o_o);
  localparam p7x96::x_t SPAT [2] = '{ 32'h31, 32'h32 };
  localparam p7x96::x_t SCAT [2] = { 32'h33, 32'h34 };
  assign o_o = SPAT[0] ^ SCAT[1];
endmodule

module top7x96 (output logic [31:0] a_o);
  logic [31:0] w, e, s;
  m7wild96 u_w (.o_o(w));
  m7expl96 u_e (.o_o(e));
  m7scop96 u_s (.o_o(s));
  assign a_o = w ^ e ^ s;
endmodule
