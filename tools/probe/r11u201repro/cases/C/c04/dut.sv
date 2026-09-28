// § clsScopedBoundWholeSpan201
class K;
  localparam int unsigned V = 6;
  localparam int unsigned W = 1;
endclass
module top (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2);
  always_comb y1 = x[K::V:K::W];
  always_comb y2[K::V:0] = x[6:0];
endmodule
