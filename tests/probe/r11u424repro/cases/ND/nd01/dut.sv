// residue (no law landed): a net-declaration assignment whose right side is a system call (sv-tests p599), see README
module driver (net_r);
output [64:1] net_r;
real r;
wire [64:1] net_r = $realtobits(r);
endmodule
