// § genLoopDirectBoundPaConst262 (a body localparam as a part-select bound, header list, whole right side)
module ctrl #(parameter bit E = 1) (input logic [7:0] a, output logic [1:0] q);
  localparam int K = 2;
  for (genvar h = 0; h < 1; h++) begin : gf
    assign q = a[K:K-1];
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q);
  ctrl u (.a(a), .q(q));
endmodule
