// § shareDefParamTsOwnNotImport262 (two packages declaring the name, the module declares it too)
package fp;
  localparam int K = 5;
endpackage
package gp;
  localparam int K = 6;
  localparam int G = 1;
endpackage
module er import fp::*; import gp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam int K = 3;
  assign q = a + G;
endmodule
module top(input logic [7:0] a, output logic [7:0] q);
  er u (.a(a), .q(q));
endmodule
