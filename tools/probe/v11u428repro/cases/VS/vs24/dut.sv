// § ndaWholeSysCallSharesLhs428
module m(input [7:0] x, input clk, output [3:0] y);
  logic [7:0] v;
  always @(posedge clk) v <= x;
  wire [3:0] n = $countones(v);
  assign y = n;
endmodule
module top(input [7:0] a, input clk, output [3:0] c, d);
  m u1(.x(a), .clk(clk), .y(c));
  m u2(.x(a), .clk(clk), .y(d));
endmodule
