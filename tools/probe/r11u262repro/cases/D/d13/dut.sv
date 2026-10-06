// § shareDefParamTsOwnNotImport262 (header parameter, not overridden, literal default, the package value equal)
package fp;
  localparam int K = 2;
endpackage
module er import fp::*; #(parameter int K = 2) (input logic [7:0] a, output logic [7:0] q);
  assign q = a;
endmodule
module top(input logic [7:0] a, output logic [7:0] q);
  er u (.a(a), .q(q));
endmodule
