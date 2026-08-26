// r10v96 adversarial arm v6 -- a SUBMODULE that imports the SAME package as its
// parent (both materialize their own copies), the same package parameter used
// from THREE instantiations of one span, and a module that both imports the
// package AND declares its own typedef alias of the imported one.
// MEASUREMENT ONLY.
package p6c96;
  typedef logic [31:0] q_t;
  localparam q_t QARR [4] = '{ 32'h1, 32'h2, 32'h3, 32'h4 };
endpackage

module leaf6c96 import p6c96::*; #(parameter int unsigned K = 0)
                                 (output logic [31:0] o_o);
  localparam q_t LQ [2] = '{ 32'h91, 32'h92 };
  assign o_o = QARR[K] ^ LQ[0];
endmodule

module mid6c96 import p6c96::*; (output logic [31:0] o_o);
  typedef q_t alias_t;                       // alias of the IMPORTED typedef
  localparam alias_t AQ [2] = '{ 32'ha1, 32'ha2 };
  logic [31:0] a, b, c;
  leaf6c96 #(.K(0)) u_0 (.o_o(a));
  leaf6c96 #(.K(1)) u_1 (.o_o(b));
  leaf6c96 #(.K(2)) u_2 (.o_o(c));
  assign o_o = a ^ b ^ c ^ AQ[1];
endmodule

module top6c96 (output logic [31:0] a_o);
  mid6c96 u_m (.o_o(a_o));
endmodule
