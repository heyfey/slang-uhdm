// § caUnitEnumUnresolvedShares290
`include "hdr.svh"
module top(output cmd_e o, output cmd_e o2, output cmd_e o3);
assign o = E_RD;
assign o2 = E_WR;
assign o3 = E_ERR;
m1 u(.i(), .o1());
endmodule
