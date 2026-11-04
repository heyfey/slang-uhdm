// § genLoopDirectBoundPaConst262 (for-generate, overridden width select as an operand)
module m #(parameter int Width = 32) (input logic [7:0] a, input logic [5:0] b, output logic [5:0] q);
  for (genvar i = 0; i < 2; i++) begin : gf
    assign q[i*3+:3] = a[i+:Width] & b[i*3+:3];
  end
endmodule
module top(input logic [7:0] a, input logic [5:0] b, output logic [5:0] q);
  m #(.Width(3)) u (.*);
endmodule
