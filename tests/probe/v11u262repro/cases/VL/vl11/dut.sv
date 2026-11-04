// § genLoopDirectBoundPaConst262 (two instances with different overrides, a direct bound in a for-generate)
module sub #(parameter int W = 3) (input logic [7:0] a, output logic [3:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : gf
    assign o[i] = a[W:0];
  end
endmodule
module top(input logic [7:0] a, output logic [3:0] o [2], output logic [3:0] p [2]);
  sub #(.W(1)) u(.a(a), .o(o));
  sub #(.W(2)) v(.a(a), .o(p));
endmodule
