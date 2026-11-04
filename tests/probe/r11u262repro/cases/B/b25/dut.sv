// § genLoopDirectBoundPaConst262 (for-generate, gen-local plain LHS, overridden width)
module m #(parameter int Width = 32) (input logic [7:0] a, output logic [5:0] q);
  for (genvar i = 0; i < 2; i++) begin : gf
    logic [2:0] t;
    assign t = a[i+:Width];
    assign q[i*3+:3] = t;
  end
endmodule
module top(input logic [7:0] a, output logic [5:0] q);
  m #(.Width(3)) u (.*);
endmodule
