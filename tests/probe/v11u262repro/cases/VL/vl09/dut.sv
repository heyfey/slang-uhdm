// § genLoopDirectBoundPaConst262 (a parameter as a bit-select index and as a bound operand: control)
module sub #(parameter int W = 3) (input logic [7:0] a, output logic [3:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : gf
    assign o[i] = {a[W], a[W-1:0]};
  end
endmodule
module top(input logic [7:0] a, output logic [3:0] o [2]);
  sub u(.a(a), .o(o));
endmodule
