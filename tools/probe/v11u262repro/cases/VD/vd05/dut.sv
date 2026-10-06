// § shareDefParamTsOwnNotImport262 (body localparam read in an always_comb inside a for-generate)
package rp;
  localparam int K = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [1:0] q);
  localparam int K = 2;
  for (genvar h = 0; h < 1; h++) begin : gf
    always_comb q = a[K +: 2];
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q);
  ctrl u (.a(a), .q(q));
endmodule
