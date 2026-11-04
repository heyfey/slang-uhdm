// § shareDefParamTsOwnNotImport262 (no shadowing: control)
package fp;
  localparam int K = 5;
endpackage
module er import fp::*; #(parameter int W = 2) (input logic [7:0] a, output logic [7:0] q);
  assign q = a + K + W;
endmodule
module top(input logic [7:0] a, output logic [7:0] q);
  er u (.a(a), .q(q));
endmodule
