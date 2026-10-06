// § loopBoundBinOperandPlainLhs262v (a header parameter, a for-generate reading the name)
package rp;
  localparam int K = 2;
endpackage
module ctrl import rp::*; #(parameter bit E = 1) (input logic [7:0] a, output logic [1:0] q, output logic [1:0] r);
  localparam int K = 2;
  assign r = a[1:0];
  for (genvar h = 0; h < 1; h++) begin : gf
    assign q = a[K +: 2] & {2{E}};
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q, output logic [1:0] r);
  ctrl u (.a(a), .q(q), .r(r));
endmodule
