// § vsTrailRangeParenStart453
`define LO (2)
module top;
  logic [3:0][7:0] q;
  logic [1:0] y;
  assign y = q[1][3:`LO];
endmodule
