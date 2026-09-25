// r11u161 gen path: cont-assign LHS through a generate-array element (a select in the middle of the path)
module top(input logic [1:0] a, output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    wire x;
  end
  if (1) begin : h
    assign g[0].x = a[0];
    assign g[1].x = a[1];
  end
  assign o = {g[1].x, g[0].x};
endmodule
