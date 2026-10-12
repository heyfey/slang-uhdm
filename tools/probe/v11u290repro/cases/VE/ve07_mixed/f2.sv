// § caUnitEnumUnresolvedShares290
`include "hdr.svh"
module top(output logic o, p, q);
typedef enum logic { L_A = 1'b1 } loc_e;
assign o = E_RD;
assign p = L_A;
assign q = E_WR;
m1 u(.o1());
endmodule
