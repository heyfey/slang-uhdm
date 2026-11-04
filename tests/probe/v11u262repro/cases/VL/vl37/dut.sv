// § loopBoundBinOperandPlainLhs262v (nested two levels in binary operations, plain left side)
module ctrl (input logic [7:0] a, output logic [1:0] q);
  localparam int K = 2;
  for (genvar h = 0; h < 1; h++) begin : gf
    logic [1:0] t;
    assign q = (a[K +: 2] & 2'b11) | a[1:0];
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q);
  ctrl u (.a(a), .q(q));
endmodule
