// § shareDefParamTsOwnNotImport262 (package imported in the body, not the header)
package fp;
  localparam int K = 5;
endpackage
module er (input logic [7:0] a, output logic [7:0] q);
  import fp::*;
  localparam int K = 3;
  assign q = a + K;
endmodule
module top(input logic [7:0] a, output logic [7:0] q);
  er u (.a(a), .q(q));
endmodule
