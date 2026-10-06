// § shareDefParamTsOwnNotImport262 (body localparam as an if-generate condition)
package rp;
  localparam int K = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [1:0] q);
  localparam int K = 2;
  if (K == 2) begin : g
    assign q = a[1:0];
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q);
  ctrl u (.a(a), .q(q));
endmodule
