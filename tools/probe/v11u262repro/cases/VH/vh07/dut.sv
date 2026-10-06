// § shareDefParamTsOwnNotImport262 (two header parameters, the shadowing one overridden at the instance)
package rp;
  localparam int K = 2;
endpackage
module ctrl import rp::*; #(parameter int K = 2, parameter bit E = 1) (input logic [7:0] a, output logic [1:0] r);
  assign r = a[K +: 2] & {2{E}};
endmodule
module top(input logic [7:0] a, output logic [1:0] r);
  ctrl #(.K(3)) u (.a(a), .r(r));
endmodule
