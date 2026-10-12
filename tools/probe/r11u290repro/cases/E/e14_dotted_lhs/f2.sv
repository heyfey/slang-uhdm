// § caUnitEnumUnresolvedShares290
`include "hdr.svh"
module top();
typedef struct packed { logic a; logic b; } s_t;
s_t v;
assign v.a = E_RD;
m1 u(.i(), .o1());
endmodule
