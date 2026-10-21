// residue (no law landed): a net-declaration assignment whose right side is a system call (sv-tests p599), see README
module top (input logic [7:0] a);
  real r;
  wire [63:0] w1 = $realtobits(r);
  wire [7:0] w2 = $signed(a);
  wire [7:0] w3 = $clog2(a);
  wire [7:0] w4 = $unsigned(a);
  wire [31:0] w5 = $countones(a);
endmodule
