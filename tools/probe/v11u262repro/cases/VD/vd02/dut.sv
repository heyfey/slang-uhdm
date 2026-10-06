// § shareDefParamTsOwnNotImport262 (body localparam named only in a comment inside an if-generate block)
package rp;
  localparam int K = 2;
endpackage
module ctrl import rp::*; #(parameter bit E = 1) (input logic [7:0] a, output logic [1:0] q, output logic [7:0] r);
  localparam int K = 2;
  assign r = a[K +: 2];
  if (E) begin : g
    // K is not read here
    assign q = a[1:0];
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q, output logic [7:0] r);
  ctrl u (.a(a), .q(q), .r(r));
endmodule
