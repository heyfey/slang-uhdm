// § genLoopDirectBoundPaConst262 (a direct bound inside a concatenation and a replication in a for-generate)
module sub #(parameter int W = 3, localparam int L = 1) (input logic [7:0] a, output logic [7:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : gf
    assign o[i] = {a[W:L], {2{a[i +: W]}}};
  end
endmodule
module top(input logic [7:0] a, output logic [7:0] o [2]);
  sub u(.a(a), .o(o));
endmodule
