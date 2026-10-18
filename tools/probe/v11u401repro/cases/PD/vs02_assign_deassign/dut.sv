// § deassignReleaseObj401
module top;
  logic q, d, clk;
  always @(clk) if (clk) assign q = d; else deassign q;
endmodule
