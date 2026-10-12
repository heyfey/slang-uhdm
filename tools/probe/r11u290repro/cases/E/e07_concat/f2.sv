// § caUnitEnumUnresolvedShares290
`include "hdr.svh"
module top(output logic [1:0] o);
assign o = {E_RD, E_WR};
m1 u(.i(), .o1());
endmodule
