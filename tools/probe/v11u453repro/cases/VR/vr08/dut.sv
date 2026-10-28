// § vsTrailRangeParenStart453
`define SEL(x) x[1][(3):2]
module top;
  logic [3:0][7:0] q;
  logic [1:0] y;
  assign y = `SEL(q);
endmodule
