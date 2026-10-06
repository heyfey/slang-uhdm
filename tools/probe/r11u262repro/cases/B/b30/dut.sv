// § genLoopDirectBoundPaConst262 (for-generate, module localparam as a direct bound and width)
module m #(parameter int Width = 32) (input logic [7:0] a, output logic [5:0] q);
  localparam int LW = 3;
  for (genvar i = 0; i < 2; i++) begin : gf
    assign q[i*3+:3] = a[i+:LW] | a[LW:1];
  end
endmodule
module top(input logic [7:0] a, output logic [5:0] q);
  m #(.Width(3)) u (.*);
endmodule
