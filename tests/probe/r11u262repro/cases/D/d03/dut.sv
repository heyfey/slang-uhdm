// § shareDefParamTsOwnNotImport262 (untyped module parameter shadowing a typed package parameter)
package fp;
  parameter int W = 4;
endpackage
module er import fp::*; #(parameter W = 4) (input logic [7:0] a, output logic [7:0] q);
  assign q = a;
endmodule
module top(input logic [7:0] a, output logic [7:0] q);
  er u (.a(a), .q(q));
endmodule
