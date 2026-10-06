// § shareDefParamTsOwnNotImport262 (logic-vector module localparam shadowing an int package parameter, different values)
package fp;
  localparam int K = 5;
endpackage
module er import fp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam logic [3:0] K = 4'd3;
  assign q = a + K;
endmodule
module top(input logic [7:0] a, output logic [7:0] q);
  er u (.a(a), .q(q));
endmodule
