// r10earl96 arm g4 — HOMES: the head shape (an unpacked-array parameter of a
// package typedef, wildcard-imported) at a MODULE TOP, in a SUBMODULE, inside
// a GENERATE SCOPE, in an INTERFACE, and in THREE INSTANTIATIONS of ONE span.
// MEASUREMENT ONLY.
package p4h96;
  typedef logic [31:0] h_t;
  localparam h_t HARR [4] = '{ 32'h1, 32'h2, 32'h3, 32'h4 };
endpackage

interface if4h96 import p4h96::*; ();
  logic [31:0] v;
  assign v = HARR[3];
endinterface

module sub4h96 import p4h96::*; #(parameter int unsigned K = 0)
                                 (output logic [31:0] o_o);
  assign o_o = HARR[K];
endmodule

module m4h96 import p4h96::*; (output logic [31:0] o_o);
  logic [31:0] s0, s1, s2, gv;
  sub4h96 #(.K(0)) u_s0 (.o_o(s0));     // three instantiations of ONE span
  sub4h96 #(.K(1)) u_s1 (.o_o(s1));
  sub4h96 #(.K(2)) u_s2 (.o_o(s2));
  if (1) begin : g4gen                  // a GEN SCOPE home
    localparam h_t GARR [2] = '{ 32'h7, 32'h8 };
    assign gv = GARR[1] ^ HARR[0];
  end
  if4h96 u_if ();
  assign o_o = s0 ^ s1 ^ s2 ^ gv ^ u_if.v;
endmodule

module top4h96 (output logic [31:0] a_o);
  m4h96 u_a (.o_o(a_o));
endmodule
