// r10v96 adversarial arm v2 -- a RE-EXPORT chain: a middle package that
// EXPLICITLY imports and RE-EXPORTS another package's typedef and array
// parameter, declares its OWN array parameter of the imported typedef, and a
// module that wildcard-imports the MIDDLE package.  MEASUREMENT ONLY.
package pbase2v96;
  typedef logic [31:0] b_t;
  localparam b_t BASEARR [4] = '{ 32'h1, 32'h2, 32'h3, 32'h4 };
endpackage

package pmid2v96;
  import pbase2v96::b_t;
  import pbase2v96::BASEARR;
  export pbase2v96::b_t;
  export pbase2v96::BASEARR;
  localparam b_t MIDARR [4] = '{ 32'h5, 32'h6, 32'h7, 32'h8 };
endpackage

module m2mid96 import pmid2v96::*; (output logic [31:0] o_o);
  localparam b_t MODARR [2] = '{ 32'h9, 32'ha };
  assign o_o = MIDARR[1] ^ BASEARR[2] ^ MODARR[0];
endmodule

module top2v96 (output logic [31:0] a_o);
  m2mid96 u_m (.o_o(a_o));
endmodule
