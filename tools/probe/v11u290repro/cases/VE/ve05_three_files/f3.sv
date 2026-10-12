// § caUnitEnumUnresolvedShares290
`include "hdr.svh"
module top(output logic o, p, q);
assign o = E_WR;
m1 x(.o1(p));
m2 y(.o(q));
endmodule
