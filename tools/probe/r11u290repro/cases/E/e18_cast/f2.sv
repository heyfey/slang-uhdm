// § caUnitEnumUnresolvedShares290
`include "hdr.svh"
module top(output logic o);
assign o = cmd_e'(E_RD);
m1 u(.i(), .o1());
endmodule
