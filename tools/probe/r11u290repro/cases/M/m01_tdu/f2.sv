// § elabMisevalSpliceRefChain290
`include "hdrb.svh"
module top(output logic [3:0] o);
localparam int unsigned MT = P_MTRIG;
localparam int unsigned AT = P_ALL;
localparam int unsigned AW = $clog2(AT+1);
logic [MT-1:0] a;
logic [MT-1:0] b;
logic [AW-1:0] c;
logic [AW-1:0] d;
assign d = AW'(1);
assign o = {a[0], b[0], c[0], d[0]};
first_claim u();
endmodule
