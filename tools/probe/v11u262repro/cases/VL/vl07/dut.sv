// § genLoopDirectBoundPaConst262 (instance depth 3, an overridden parameter direct bound in a for-generate)
module leaf #(parameter int W = 3) (input logic [7:0] a, output logic [3:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : gf
    assign o[i] = a[W:i];
  end
endmodule
module mid #(parameter int W = 2) (input logic [7:0] a, output logic [3:0] o [2]);
  leaf #(.W(W)) l(.a(a), .o(o));
endmodule
module top(input logic [7:0] a, output logic [3:0] o [2]);
  mid #(.W(1)) m(.a(a), .o(o));
endmodule
