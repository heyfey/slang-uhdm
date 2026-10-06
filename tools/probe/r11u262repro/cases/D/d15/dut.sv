// § shareDefParamTsOwnNotImport262 (body localparam with a system-call initializer over a literal)
package fp;
  localparam int K = 3;
endpackage
module er import fp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam int K = $clog2(8);
  assign q = a;
endmodule
module top(input logic [7:0] a, output logic [7:0] q);
  er u (.a(a), .q(q));
endmodule
