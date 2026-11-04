// § genLoopDirectBoundPaConst262 (a header parameter shadowing an imported package parameter, a for-generate indexed width)
package rp;
  parameter int K = 2;
endpackage
module ctrl import rp::*; #(parameter int K = 2) (input logic [7:0] a, output logic [1:0] q);
  for (genvar h = 0; h < 1; h++) begin : gf
    assign q = a[K +: 2];
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q);
  ctrl #(.K(2)) u (.a(a), .q(q));
endmodule
