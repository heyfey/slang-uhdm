// § wildcardConnRefSpan130
module top(input logic clk, input logic d, output logic q);
  always_ff @(posedge clk) q <= d;
endmodule
module chk(input logic clk, input logic d);
  logic seen;
  always_ff @(posedge clk) seen <= d;
endmodule
bind top chk u_chk (.*);
