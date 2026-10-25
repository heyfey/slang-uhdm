// § typedLitElabAdjustLogic427
module lfsr_16bit #(parameter logic [15:0] SEED = 8'b0, parameter int unsigned WIDTH = 16)(input logic clk, output logic [15:0] q);
  logic [15:0] r;
  always_ff @(posedge clk) r <= (r == '0) ? SEED : {r[14:0], r[15]};
  assign q = r;
endmodule
module top(input logic clk, output logic [15:0] q, output logic [15:0] p);
  lfsr_16bit u(.clk(clk), .q(q));
  lfsr_16bit #(.WIDTH(8)) v(.clk(clk), .q(p));
endmodule
