// § elabMisevalCompositeShares290
parameter P_LOCAL = 1'b1;
`include "hdr.svh"
module dmi(output logic o);
localparam OP_LO = 5'd0;
localparam OP_HI = OP_LO + P_OPW - 1;
localparam D_LO  = OP_HI + 1;
localparam D_HI  = D_LO + P_DW - 1;
logic [D_HI:D_LO] r;
assign o = r[D_LO];
endmodule
module top(output logic o);
dmi d(.o(o));
first_claim u();
endmodule
