// § clockingEventDefNet139
module sub #(parameter int W = 1)(input logic clk, input logic [W-1:0] d, output logic [W-1:0] q);
  default clocking cb @(posedge clk); endclocking
  always_ff @(posedge clk) q <= d;
endmodule
module top(input logic clk, input logic [3:0] d, output logic [3:0] q1, output logic q2);
  sub #(.W(4)) u1(.clk(clk), .d(d), .q(q1));
  sub u2(.clk(clk), .d(d[0]), .q(q2));
endmodule
