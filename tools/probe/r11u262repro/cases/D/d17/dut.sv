// § shareDefParamTsOwnNotImport262 (body localparam reading another package parameter)
package fp;
  localparam int J = 2;
  localparam int K = 4;
endpackage
module er import fp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam int K = J * 2;
  assign q = a;
endmodule
module top(input logic [7:0] a, output logic [7:0] q);
  er u (.a(a), .q(q));
endmodule
