// § genLoopDirectBoundPaConst262 (overridden typed parameter as a part-select LEFT bound minus one inside the for-generate: control of pass 256)
module m #(parameter int Width = 32) (input logic [7:0] a, output logic [5:0] q);
  for (genvar i = 0; i < 2; i++) begin : gf
    assign q[i*3+:3] = a[i+:Width];
  end
endmodule
module top(input logic [7:0] a, output logic [5:0] q);
  m #(.Width(3)) u (.*);
endmodule
