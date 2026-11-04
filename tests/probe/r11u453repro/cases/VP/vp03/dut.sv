// § vsTrailRangeParenStart453
module top;
  logic [3:0][7:0] q;
  logic [1:0] y;
  always_comb y = q[1][3:(2)];
endmodule
