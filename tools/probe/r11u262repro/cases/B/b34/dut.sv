// § genLoopDirectBoundPaConst262 (for-generate, a genvar-dependent bound beside the parameter bound)
module m #(parameter int Width = 32) (input logic [7:0] a, output logic [5:0] q);
  for (genvar i = 0; i < 2; i++) begin : gf
    assign q[i*3+:3] = a[Width:i] ^ a[i+2:Width-1];
  end
endmodule
module top(input logic [7:0] a, output logic [5:0] q);
  m #(.Width(3)) u (.*);
endmodule
