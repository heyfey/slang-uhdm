// § shareDefParamTsOwnNotImport262 (untyped body localparam, the package typed, the values equal)
package fp;
  localparam int K = 3;
endpackage
module er import fp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam K = 3;
  assign q = a;
endmodule
module top(input logic [7:0] a, output logic [7:0] q);
  er u (.a(a), .q(q));
endmodule
