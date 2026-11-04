// § bodyParamNoHdrList262v (a body parameter shadowing a package parameter read as a for-generate bound and an if-generate condition)
package rp;
  parameter int K = 2;
endpackage
module ctrl import rp::*; #(parameter bit E = 1) (input logic [7:0] a, output logic [1:0] q);
  parameter int K = 2;
  if (K > 1) begin : g
    assign q = a[1:0];
  end
  for (genvar h = 0; h < K; h++) begin : gf
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q);
  ctrl u (.a(a), .q(q));
endmodule
