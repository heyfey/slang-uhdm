// § caUnitEnumUnresolvedShares290
`include "hdr.svh"
module sub(output cmd_e o);
assign o = E_RD;
endmodule
module top();
sub s1(.o());
sub s2(.o());
m1 u(.i(), .o1());
endmodule
