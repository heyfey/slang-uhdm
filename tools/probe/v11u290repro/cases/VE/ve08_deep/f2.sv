// § caUnitEnumUnresolvedShares290
`include "hdr.svh"
module leaf(output logic o);
assign o = E_RD;
endmodule
module mid(output logic o);
leaf l(.o(o));
endmodule
module top(output logic o);
mid m(.o(o));
m1 u(.o1());
endmodule
