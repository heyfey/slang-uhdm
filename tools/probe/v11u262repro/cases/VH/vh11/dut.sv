// § shareDefParamTsOwnNotImport262 (no header list, a body parameter (not localparam) read, and another body parameter overridden)
package rp;
  localparam int K = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [1:0] r);
  parameter int K = 2;
  parameter bit E = 1;
  assign r = a[K +: 2] & {2{E}};
endmodule
module top(input logic [7:0] a, output logic [1:0] r);
  ctrl #(.E(1)) u (.a(a), .r(r));
endmodule
