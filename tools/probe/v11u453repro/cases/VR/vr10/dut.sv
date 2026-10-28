// § vsTrailRangeParenStart453
module top;
  logic [3:0][7:0] q;
  logic [3:0] y;
  int k;
  always_comb y = {q[k][(k)+:2], q[1][(1):0]};
endmodule
