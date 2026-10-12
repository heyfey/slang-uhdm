// § caUnitEnumUnresolvedShares290
`include "hdr.svh"
module top(input logic s, output logic o);
always_comb case (s) E_RD: o = 1'b1; default: o = 1'b0; endcase
m1 u(.i(), .o1());
endmodule
