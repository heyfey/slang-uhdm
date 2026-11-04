// § vsTrailRangeParenStart453
module top;
  logic [3:0][7:0] q;
  logic [7:0] y;
  int k;
  always_comb y = 8'(q[k][(k)+:2]) + 8'(q[1][(3):(2)]);
endmodule
