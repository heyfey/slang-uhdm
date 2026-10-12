// § caUnitEnumUnresolvedShares290
`include "hdr.svh"
module sub #(parameter int W = 1)(output logic [W-1:0] o);
assign o = E_RD;
endmodule
module top(output logic [1:0] o);
sub #(.W(2)) s(.o(o));
m1 u(.o1());
endmodule
