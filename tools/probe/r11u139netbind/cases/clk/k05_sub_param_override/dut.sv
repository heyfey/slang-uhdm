module sub #(parameter W = 1) (input clk, input [W-1:0] a, output logic [W-1:0] y);
  default clocking @(posedge clk); endclocking
  always @(posedge clk) y <= a;
endmodule
module top(input clk, input [3:0] a, output [3:0] y, output [1:0] z);
  sub #(.W(4)) u1(.clk(clk), .a(a), .y(y));
  sub #(.W(2)) u2(.clk(clk), .a(a[1:0]), .y(z));
endmodule
