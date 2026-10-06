// § genLoopDirectBoundPaConst262 (a for-generate inside an if-generate, the module parameter a direct indexed part-select width)
module sub #(parameter int W = 3, parameter bit E = 1) (input logic [7:0] a, output logic [2:0] o [2]);
  if (E) begin : ge
    for (genvar i = 0; i < 2; i++) begin : gf
      assign o[i] = a[i +: W];
    end
  end
endmodule
module top(input logic [7:0] a, output logic [2:0] o [2]);
  sub u(.a(a), .o(o));
endmodule
