// § shareDefParamTsOwnNotImport262 (an if-generate block declaring its own localparam of the name; the module localparam read outside)
package rp;
  localparam int K = 2;
endpackage
module ctrl import rp::*; #(parameter bit E = 1) (input logic [7:0] a, output logic [1:0] q, output logic [1:0] r);
  localparam int K = 2;
  assign r = a[K +: 2];
  if (E) begin : g
    localparam int K = 4;
    assign q = a[K +: 2];
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q, output logic [1:0] r);
  ctrl u (.a(a), .q(q), .r(r));
endmodule
