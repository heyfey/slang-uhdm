// § shareDefParamTsOwnNotImport262 (header localparam with an arithmetic initializer over a header parameter)
package fp;
  localparam int K = 3;
endpackage
module er import fp::*; #(parameter int W = 2, localparam int K = W + 1) (input logic [7:0] a, output logic [7:0] q);
  assign q = a;
endmodule
module top(input logic [7:0] a, output logic [7:0] q);
  er u (.a(a), .q(q));
endmodule
