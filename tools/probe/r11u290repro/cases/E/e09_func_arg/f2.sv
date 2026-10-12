// § caUnitEnumUnresolvedShares290
`include "hdr.svh"
module top(output logic o);
function automatic logic f(logic a); return a; endfunction
assign o = f(E_WR);
m1 u(.i(), .o1());
endmodule
