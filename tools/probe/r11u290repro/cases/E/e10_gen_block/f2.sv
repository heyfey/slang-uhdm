// § caUnitEnumUnresolvedShares290
`include "hdr.svh"
module top(output logic o);
if (1) begin : g
  assign o = E_RD;
end
m1 u(.i(), .o1());
endmodule
