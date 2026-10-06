// § loopBoundBinOperandPlainLhs262v (the select ANDed with a literal replication, header list)
module ctrl #(parameter bit E = 1) (input logic [7:0] a, output logic [1:0] q);
  localparam int K = 2;
  localparam bit L = 1;
  for (genvar h = 0; h < 1; h++) begin : gf
    assign q = a[K +: 2] & {2{1'b1}};
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q);
  ctrl u (.a(a), .q(q));
endmodule
