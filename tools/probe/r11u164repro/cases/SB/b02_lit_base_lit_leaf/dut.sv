// § defGenSelBaseLeafAtIndex164 — gen-if target: a literal-selected generate-array base, a literal-selected leaf
module top(input logic [1:0] a, output logic [3:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    wire [1:0] y;
  end
  if (1) begin : h
    assign g[0].y[1] = a[0];
    assign g[1].y[0] = a[1];
  end
  assign o = {g[1].y, g[0].y};
endmodule
