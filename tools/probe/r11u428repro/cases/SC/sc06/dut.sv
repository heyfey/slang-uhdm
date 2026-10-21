// § ndaWholeSysCallSharesLhs428
module top (net_r);
output [64:1] net_r;
real r;
wire [64:1] net_r = $realtobits(r);
endmodule
