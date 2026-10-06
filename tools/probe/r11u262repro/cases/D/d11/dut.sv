// § shareDefParamTsOwnNotImport262 (body localparam with an arithmetic initializer, the package value equal)
package fp;
  localparam int K = 2;
endpackage
module er import fp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam int L = 1;
  localparam int K = L + 1;
  assign q = a + L;
endmodule
module top(input logic [7:0] a, output logic [7:0] q);
  er u (.a(a), .q(q));
endmodule
