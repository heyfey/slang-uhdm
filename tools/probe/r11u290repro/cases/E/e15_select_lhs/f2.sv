// § caUnitEnumUnresolvedShares290
`include "hdr.svh"
module top(output logic [1:0] o);
assign o[0] = E_RD;
assign o[1] = E_WR;
m1 u(.i(), .o1());
endmodule
