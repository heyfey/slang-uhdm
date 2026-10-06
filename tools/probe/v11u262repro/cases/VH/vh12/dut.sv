// § shareDefParamTsOwnNotImport262 (no header list, the body localparam read inside an if-generate on a literal condition)
package rp;
  localparam int K = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [1:0] r);
  localparam int K = 2;
  if (1) begin : g
    assign r = a[K +: 2];
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] r);
  ctrl u (.a(a), .r(r));
endmodule
