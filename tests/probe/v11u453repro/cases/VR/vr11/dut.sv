// § vsTrailRangeParenStart453
module sub(input logic [1:0] i);
endmodule
module top;
  logic [3:0][7:0] q;
  sub u(.i(q[1][(3):2]));
endmodule
