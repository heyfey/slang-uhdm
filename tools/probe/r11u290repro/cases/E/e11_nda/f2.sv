// § caUnitEnumUnresolvedShares290
`include "hdr.svh"
module top(output logic o);
wire w = E_WR;
assign o = w;
m1 u(.i(), .o1());
endmodule
