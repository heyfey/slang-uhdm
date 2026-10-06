// § genLoopDirectBoundPaConst262 (a body localparam shadowing an imported package parameter, no header list, a for-generate indexed width)
package rp;
  localparam int K = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [1:0] q);
  localparam int K = 2;
  for (genvar h = 0; h < 1; h++) begin : gf
    assign q = a[K +: 2];
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q);
  ctrl u (.a(a), .q(q));
endmodule
