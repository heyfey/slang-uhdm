module top(input logic clk, input logic [3:0] a, output reg [3:0] y);
  (* r = 0.50 *) reg [3:0] q;
  always @(posedge clk) q <= a;
  always @(posedge clk) y <= q;
endmodule
