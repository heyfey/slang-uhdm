// § shareDefParamTsOwnNotImport262 (body localparam reading another module localparam)
package fp;
  localparam int K = 3;
endpackage
module er import fp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam int M = 3;
  localparam int K = M;
  assign q = a;
endmodule
module top(input logic [7:0] a, output logic [7:0] q);
  er u (.a(a), .q(q));
endmodule
