// § caUnitEnumUnresolvedShares290
`include "hdr.svh"
module top(input logic s, output logic o);
assign o = (s == E_RD);
m1 u(.i(), .o1());
endmodule
