// § ansiLogicLeaderFollowerNet428
module m(input clk, logic [7:0] a, b, output logic [7:0] q);
  always @(posedge clk) q <= a + b;
endmodule
module top(input clk, input [7:0] x, y, output [7:0] z);
  m u(.clk(clk), .a(x), .b(y), .q(z));
endmodule
