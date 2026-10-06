// § shareDefParamTsOwnNotImport262 (body localparam as a for-generate loop bound: Earlgrey rv_timer N_HARTS)
package rp;
  localparam int K = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [1:0] q);
  localparam int K = 2;
  for (genvar h = 0; h < K; h++) begin : gh
    assign q[h] = a[h];
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q);
  ctrl u (.a(a), .q(q));
endmodule
