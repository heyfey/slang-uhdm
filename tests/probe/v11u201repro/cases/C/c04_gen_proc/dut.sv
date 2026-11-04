// § clsScopedBoundWholeSpan201
class K;
  localparam int V = 5;
endclass
module top(input logic [15:0] x, output logic [7:0] y, output logic [7:0] y2);
  for (genvar i = 0; i < 2; i++) begin : g
    logic [7:0] t;
    assign t = x[K::V+i:i];
  end
  always_comb begin
    y = '0;
    y[K::V:0] = x[K::V:0];
  end
  assign y2 = g[1].t;
endmodule
