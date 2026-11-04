// § shareDefParamTsOwnNotImport262 (body localparam read as a net range inside an if-generate block)
package rp;
  localparam int K = 2;
endpackage
module ctrl import rp::*; #(parameter bit E = 1) (input logic [7:0] a, output logic [1:0] q);
  localparam int K = 2;
  if (E) begin : g
    logic [K-1:0] t;
    assign t = a[1:0];
    assign q = t;
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q);
  ctrl u (.a(a), .q(q));
endmodule
