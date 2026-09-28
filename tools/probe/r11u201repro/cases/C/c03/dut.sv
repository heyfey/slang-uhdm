// § clsScopedBoundWholeSpan201
class K;
  localparam int unsigned V = 6;
  localparam int unsigned W = 1;
endclass
module top (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2);
  assign y1 = x[K::V +: 2];
  assign y2 = K::V;
endmodule
