// § tfFormalTdCloneFile196: package typedefs written by a macro defined in one header, formals in a package function of a second header
`include "mac.svh"
package p;
  `DECL_T(w8_t, 8)
  `DECL_T(w3_t, 3)
`include "fns.svh"
endpackage
module top(input logic [7:0] a, output logic [7:0] o);
  import p::*;
  assign o = pass8(a, 3'd2);
endmodule
