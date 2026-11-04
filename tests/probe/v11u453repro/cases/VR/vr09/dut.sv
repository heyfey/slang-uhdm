// § vsTrailRangeParenStart453
module top;
  logic [3:0][7:0] q;
  logic [15:0] y;
  int k;
  always_comb y = 16'(q[k][(k)+:2]);
endmodule
