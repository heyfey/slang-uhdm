// § genLoopDirectBoundPaConst262 (for-generate, NON-overridden typed width: control)
module m #(parameter int Width = 3) (input logic [7:0] a, output logic [5:0] q);
  for (genvar i = 0; i < 2; i++) begin : gf
    assign q[i*3+:3] = a[i+:Width];
  end
endmodule
module top(input logic [7:0] a, output logic [5:0] q);
  m u (.*);
endmodule
