// § shareDefParamTsOwnNotImport262 (typedef-typed module parameter shadowing a package parameter)
package fp;
  typedef logic [3:0] n_t;
  localparam n_t K = 4'd5;
endpackage
module er import fp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam n_t K = 4'd3;
  assign q = a + K;
endmodule
module top(input logic [7:0] a, output logic [7:0] q);
  er u (.a(a), .q(q));
endmodule
