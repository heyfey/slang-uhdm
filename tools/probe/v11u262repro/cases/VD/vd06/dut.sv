// § shareDefParamTsOwnNotImport262 (overridden header parameter read in an if-generate, the instance overriding it)
package rp;
  parameter int K = 2;
endpackage
module ctrl import rp::*; #(parameter int K = 2, parameter bit E = 1) (input logic [7:0] a, output logic [1:0] q);
  if (E) begin : g
    assign q = a[K +: 2];
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q);
  ctrl #(.K(3)) u (.a(a), .q(q));
endmodule
