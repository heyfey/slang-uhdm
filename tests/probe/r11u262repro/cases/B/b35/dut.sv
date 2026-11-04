// § genLoopDirectBoundPaConst262 (constant slots in a for-generate: replication count, a declaration dimension bound, a cast width beside a direct bound: controls)
module m #(parameter int Width = 32) (input logic [7:0] a, output logic [5:0] q, output logic [7:0] r);
  for (genvar i = 0; i < 2; i++) begin : gf
    logic [Width-1:0] t;
    assign t = {Width{a[i]}};
    assign q[i*3+:3] = t ^ a[Width:1] ^ Width'(a[2:0]);
  end
  assign r = '0;
endmodule
module top(input logic [7:0] a, output logic [5:0] q, output logic [7:0] r);
  m #(.Width(3)) u (.*);
endmodule
