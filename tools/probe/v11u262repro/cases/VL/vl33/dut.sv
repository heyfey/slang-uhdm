// § loopBoundBinOperandPlainLhs262v (operands a width select and a part select, plain left side)
module ctrl (input logic [7:0] a, output logic [1:0] q);
  localparam int K = 2;
  for (genvar h = 0; h < 1; h++) begin : gf
    assign q = a[1 +: K] | a[K:1];
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q);
  ctrl u (.a(a), .q(q));
endmodule
