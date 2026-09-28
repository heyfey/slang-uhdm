// § clsScopedBoundWholeSpan201
class K;
  typedef enum int { E0 = 1, E1 = 3, E2 = 6 } e_t;
  localparam int V = 4;
endclass
module top(input logic [15:0] x, output logic [7:0] y, output logic [7:0] y2);
  assign y = x[K::E2:K::E0];
  assign y2 = x[K::V*2-1:K::V];
endmodule
