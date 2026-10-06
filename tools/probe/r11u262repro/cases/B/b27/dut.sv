// § genLoopDirectBoundPaConst262 (for-generate in the TOP module, typed width and direct bound: top-level control)
module top #(parameter int Width = 3) (input logic [7:0] a, output logic [5:0] q, output logic [5:0] r);
  for (genvar i = 0; i < 2; i++) begin : gf
    assign q[i*3+:3] = a[i+:Width];
    assign r[i*3+:3] = a[Width:1];
  end
endmodule
