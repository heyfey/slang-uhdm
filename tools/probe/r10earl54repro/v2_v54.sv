// v54 VERIFIER ARM v2 — DEGENERATE WIDTHS AND UNKNOWNS.
// replBinConst54 guards on !v || !isInteger || hasUnknown and then trusts
// getBitWidth().  Zero-width, x/z, count 1, a 64-bit count and a string body
// are the shapes that guard has to survive without minting a malformed
// constant (BIN: with no digits, size 0, or a value golden spells differently).
package pkv2_54;
  parameter int ZC = 0;
endpackage
module snkv2_54 #(parameter int WD = 8) (input [WD-1:0] a, output [WD-1:0] o);
  assign o = ~a;
endmodule
module v2_v54 (input logic sel, input logic [7:0] d, output logic [7:0] q);
  logic [7:0]  w1, w2, w3, w4, w5;
  logic [15:0] w6;
  logic [63:0] w7;
  // ZERO-COUNT replication inside a concat (legal only there)
  snkv2_54 #(.WD(8))  u_zero (.a({ {0{1'b1}}, 8'hA5 }), .o(w1));
  // zero count from a PACKAGE PARAMETER
  snkv2_54 #(.WD(8))  u_zpar (.a({ {pkv2_54::ZC{1'b1}}, 8'h5A }), .o(w2));
  // X and Z bodies: must not fold to a BIN of 0s
  snkv2_54 #(.WD(8))  u_xx   (.a({ sel ? d[3:0] : {4{1'bx}}, 4'h1 }), .o(w3));
  snkv2_54 #(.WD(8))  u_zz   (.a({ sel ? d[3:0] : {4{1'bz}}, 4'h2 }), .o(w4));
  // count 1
  snkv2_54 #(.WD(8))  u_one  (.a({ sel ? d[3:0] : {4{1'b1}}, {1{1'b1}}, 3'h3 }), .o(w5));
  // string-literal body
  snkv2_54 #(.WD(16)) u_str  (.a({ sel ? 8'h0 : {2{8'h41}}, 8'h7 }), .o(w6));
  // wide count
  snkv2_54 #(.WD(64)) u_big  (.a({ sel ? {32{1'b0}} : {32{1'b1}}, 32'hDEADBEEF }), .o(w7));
  assign q = w1 ^ w2 ^ w3 ^ w4 ^ w5 ^ w6[7:0] ^ w7[7:0];
endmodule
