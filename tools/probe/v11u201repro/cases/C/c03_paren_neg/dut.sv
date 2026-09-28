// § clsScopedBoundWholeSpan201
class K;
  localparam int V = 5;
  localparam int W = 2;
endclass
module top(input logic [15:0] x, output logic [7:0] y, output logic [7:0] y2, output logic [7:0] y3);
  assign y = x[(K::V):0];
  assign y2 = x[-K::W+K::V:0];
  assign y3 = x[K::V -: 3];
endmodule
