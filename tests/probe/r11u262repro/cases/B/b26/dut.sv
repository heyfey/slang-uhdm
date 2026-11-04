// § genLoopDirectBoundPaConst262 (two-level for-generate, overridden width: nested control)
module m #(parameter int Width = 32) (input logic [7:0] a, output logic [5:0] q);
  for (genvar i = 0; i < 2; i++) begin : gf
    for (genvar j = 0; j < 1; j++) begin : gg
      assign q[i*3+:3] = a[i+:Width];
    end
  end
endmodule
module top(input logic [7:0] a, output logic [5:0] q);
  m #(.Width(3)) u (.*);
endmodule
