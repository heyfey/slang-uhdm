// § caUnitEnumUnresolvedShares290
`include "hdr.svh"
module sub(output logic o);
assign o = E_WR;
endmodule
module top(output logic [1:0] o);
for (genvar i = 0; i < 2; i++) begin : g
  sub s(.o(o[i]));
end
m1 u(.o1());
endmodule
