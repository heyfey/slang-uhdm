// § loopBoundBinOperandPlainLhs262v (a body localparam, a header parameter list, no package, a for-generate indexed width)
module ctrl #(parameter bit E = 1) (input logic [7:0] a, output logic [1:0] q);
  localparam int K = 2;
  for (genvar h = 0; h < 1; h++) begin : gf
    assign q = a[K +: 2] & {2{E}};
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q);
  ctrl u (.a(a), .q(q));
endmodule
