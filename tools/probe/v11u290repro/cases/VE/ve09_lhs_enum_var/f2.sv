// § caUnitEnumUnresolvedShares290
`include "hdr.svh"
module top(output logic o);
cmd_e c;
assign c = E_WR;
assign o = c;
m1 u(.o1());
endmodule
