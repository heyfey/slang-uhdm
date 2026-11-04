// § loopBoundBinOperandPlainLhs262v (a direct operand of a binary operation inside a concatenation, plain left side)
module ctrl (input logic [7:0] a, output logic [1:0] q);
  localparam int K = 2;
  for (genvar h = 0; h < 1; h++) begin : gf
    logic [1:0] t;
    assign q = {a[K +: 1] ^ a[0], a[1]};
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q);
  ctrl u (.a(a), .q(q));
endmodule
