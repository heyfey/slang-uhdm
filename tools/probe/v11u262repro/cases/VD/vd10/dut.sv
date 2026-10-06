// § shareDefParamTsOwnNotImport262 (body localparam read in an always_comb of an if-generate, no continuous assignment)
package rp;
  localparam int K = 2;
endpackage
module ctrl import rp::*; #(parameter bit E = 1) (input logic [7:0] a, output logic [1:0] q);
  localparam int K = 2;
  if (E) begin : g
    always_comb q = a[K +: 2];
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q);
  ctrl u (.a(a), .q(q));
endmodule
