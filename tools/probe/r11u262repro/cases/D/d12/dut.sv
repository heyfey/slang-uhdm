// § shareDefParamTsOwnNotImport262 (body localparam with a sized literal initializer, the package value equal)
package fp;
  localparam int K = 3;
endpackage
module er import fp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam int K = 32'd3;
  assign q = a;
endmodule
module top(input logic [7:0] a, output logic [7:0] q);
  er u (.a(a), .q(q));
endmodule
