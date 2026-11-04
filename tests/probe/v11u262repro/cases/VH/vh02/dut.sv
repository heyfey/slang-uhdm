// § shareDefParamTsOwnNotImport262 (no header parameter; an if-generate on a literal condition not reading the name)
package rp;
  localparam int K = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [1:0] q, output logic [1:0] r);
  localparam int K = 2;
  assign r = a[K +: 2];
  if (1) begin : g
    assign q = a[1:0];
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q, output logic [1:0] r);
  ctrl u (.a(a), .q(q), .r(r));
endmodule
