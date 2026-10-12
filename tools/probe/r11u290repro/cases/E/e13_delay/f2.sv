// § caUnitEnumUnresolvedShares290
`include "hdr.svh"
module top(output logic o);
assign #1 o = E_WR;
m1 u(.i(), .o1());
endmodule
