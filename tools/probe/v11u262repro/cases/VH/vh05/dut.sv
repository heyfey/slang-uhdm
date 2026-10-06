// § shareDefParamTsOwnNotImport262 (a body localparam as an if-generate condition, no header parameter, the name also read outside)
package rp;
  localparam int K = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [1:0] q, output logic [1:0] r);
  localparam int K = 2;
  localparam bit F = 1;
  assign r = a[K +: 2];
  if (F) begin : g
    assign q = a[1:0];
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q, output logic [1:0] r);
  ctrl u (.a(a), .q(q), .r(r));
endmodule
