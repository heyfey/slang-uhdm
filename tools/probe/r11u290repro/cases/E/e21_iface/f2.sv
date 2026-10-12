// § caUnitEnumUnresolvedShares290
`include "hdr.svh"
interface ifc();
logic o;
assign o = E_RD;
endinterface
module top();
ifc u_i();
m1 u(.i(), .o1());
endmodule
