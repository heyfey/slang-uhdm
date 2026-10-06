// § loopBoundBinOperandPlainLhs262v (vl15 with the header parameter overridden to a different value)
module ctrl #(parameter bit E = 1) (input logic [7:0] a, output logic [1:0] q);
  localparam int K = 2;
  for (genvar h = 0; h < 1; h++) begin : gf
    assign q = a[K +: 2] & {2{E}};
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q);
  ctrl #(.E(0)) u (.a(a), .q(q));
endmodule
