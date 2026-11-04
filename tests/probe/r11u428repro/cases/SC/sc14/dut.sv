// § ndaWholeSysCallSharesLhs428
module top(input clk, input [3:0] x);
  wire [31:0] t = $time;
  wire [3:0] r;
  assign r = $random(x);
endmodule
