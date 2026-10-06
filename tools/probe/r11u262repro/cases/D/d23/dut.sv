// § shareDefParamTsOwnNotImport262 (untyped header parameter overridden)
package fp;
  localparam int K = 3;
endpackage
module er import fp::*; #(parameter K = 2) (input logic [7:0] a, output logic [7:0] q);
  assign q = a;
endmodule
module top(input logic [7:0] a, output logic [7:0] q);
  er #(.K(3)) u (.a(a), .q(q));
endmodule
