// § genLoopDirectBoundPaConst262 (a for-generate localparam shadowing the module parameter, read as a direct part-select bound)
module sub #(parameter int W = 3) (input logic [7:0] a, output logic [3:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : gf
    localparam int W = 1;
    assign o[i] = a[W:0];
  end
endmodule
module top(input logic [7:0] a, output logic [3:0] o [2]);
  sub u(.a(a), .o(o));
endmodule
