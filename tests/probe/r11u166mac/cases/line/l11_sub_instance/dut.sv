// § ppOutputLine166
`define REG(q, d) \
  always_ff @(posedge clk) \
    q <= d;
module sub #(parameter W = 2) (input clk, input [W-1:0] d, output logic [W-1:0] q);
  `REG(q, d)
endmodule
module top(input clk, input [3:0] d, output [3:0] q);
  sub #(.W(4)) u (.clk(clk), .d(d), .q(q));
endmodule
