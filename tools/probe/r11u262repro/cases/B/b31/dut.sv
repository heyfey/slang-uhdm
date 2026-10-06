// § genLoopDirectBoundPaConst262 (for-generate, logic-vector typed parameter as a direct bound and width)
module m #(parameter logic [3:0] Width = 4'd9) (input logic [7:0] a, output logic [5:0] q);
  for (genvar i = 0; i < 2; i++) begin : gf
    assign q[i*3+:3] = a[i+:Width] | a[Width:1];
  end
endmodule
module top(input logic [7:0] a, output logic [5:0] q);
  m #(.Width(3)) u (.*);
endmodule
