// § unpackedDimBasedLitKept454
module top(input logic clk, input logic [1:0] ad, input logic [7:0] d, output logic [7:0] q);
  logic [7:0] mem [2'd0:2'd3];
  always_ff @(posedge clk) mem[ad] <= d;
  assign q = mem[ad];
endmodule
