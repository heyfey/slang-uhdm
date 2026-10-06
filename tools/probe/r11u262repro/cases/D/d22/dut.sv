// § shareDefParamTsOwnNotImport262 (header parameter overridden with the package's value)
package fp;
  localparam int K = 3;
endpackage
module er import fp::*; #(parameter int K = 2) (input logic [7:0] a, output logic [7:0] q);
  assign q = a;
endmodule
module top(input logic [7:0] a, output logic [7:0] q);
  er #(.K(3)) u (.a(a), .q(q));
endmodule
