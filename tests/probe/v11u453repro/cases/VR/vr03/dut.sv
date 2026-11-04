// § vsTrailRangeParenStart453
module top;
  logic [3:0][7:0] q;
  int k;
  always_comb q[k][(k)-:2] = 2'b1;
endmodule
